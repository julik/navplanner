module ParserLoader
  extend self
  
  def parse_navaids(points)
    nav_dat = File.join(ENV.fetch('X_PLANE_INSTALL_PATH'), 'Resources/default data/earth_nav.dat')
    File.open(nav_dat, 'rb') do |f|
      3.times { f.gets }
      while line = f.gets
        break if line.strip == '99'
        parts = line.split(/\s+/)
        type = parts.shift.to_i
        case type
        when 2,3
          lat = parts.shift.to_f
          lon = parts.shift.to_f
          elev_ft = parts.shift.to_f
          freq_int = parts.shift.to_i
          reception_range_nm = parts.shift.to_f
          mag_var_deg = parts.shift.to_f
          ident = parts.shift
          name = parts.join(' ')
          if type == 2
            points << NDB.new(lat, lon, ident, name, elev_ft, freq_int, reception_range_nm)
          else
            points << VOR.new(lat, lon, ident, name, elev_ft, freq_int, reception_range_nm)
          end
        when 12, 13
          lat = parts.shift.to_f
          lon = parts.shift.to_f
          elev_ft = parts.shift.to_f
          freq_int = parts.shift.to_i
          reception_range_nm = parts.shift.to_f
          nm_dme_bias = parts.shift.to_f
          ident = parts.shift
          name = parts.join(' ')
          points << DME.new(lat, lon, ident, name, elev_ft, freq_int, nm_dme_bias)
        end
      end
    end
  end
  
  def parse_fixes(points)
    fix_dat_path = nav_dat = File.join(ENV.fetch('X_PLANE_INSTALL_PATH'), 'Resources/default data/earth_fix.dat')
    File.open(fix_dat_path, 'rb') do |f|
      3.times { f.gets }
      while line = f.gets
        break if line.strip == '99'
        lat, lon, name = line.strip.split(/\s+/)
        points << FIX.new(lat.to_f, lon.to_f, name, name)
      end
    end
  end
  
  def parse_airports(points)
    apt_dat_path = File.join(ENV.fetch('X_PLANE_INSTALL_PATH'), 'Resources/default scenery/default apt dat/Earth nav data/apt.dat')
    File.open(apt_dat_path, 'rb') do |f|
      3.times { f.gets }
      last_apt = nil
      defining_lats = []
      defining_lons = []
      while line = f.gets
        break if line.strip == '99'
        parts = line.split(/\s+/)
        if parts[0] == '1'
          if last_apt
            if defining_lats.any?
              avg_lat = defining_lats.inject(&:+) / defining_lats.length
              avg_lon = defining_lons.inject(&:+) / defining_lons.length
              last_apt.lat = avg_lat
              last_apt.lon = avg_lon
              points << last_apt
            else
              $stderr.puts "No runways defined for #{last_apt.inspect}"
            end
            defining_lats = []
            defining_lons = []
          end
          apt_id = parts[4]
          apt_name = parts[5..-1].join(' ')
          last_apt = APT.new(0.0, 0.0, apt_id, apt_name)
        end
        if parts[0] == '100' # Runway, formatted like "100 30.48 1 0 0.25 0 2 0 12  41.25261908 -072.03575022    0   69 2 0 0 1 30  41.25141173 -072.02738496    0   71 2 0 0 1"
          defining_lats << parts[9].to_f
          defining_lons << parts[10].to_f
          defining_lats << parts[18].to_f
          defining_lons << parts[19].to_f
        end
      end
    end
  end
  
  def parse_and_cache
    points = []
    parser_threads = [
      Thread.new { parse_navaids(points) },
      Thread.new { parse_fixes(points) },
      Thread.new { parse_airports(points) }
    ]
    parser_threads.map(&:join)
    $stderr.puts "Found %d navaids, fixes and airports" % points.length
    File.open("cached_nav.marshal", "wb") do |f|
      f << Marshal.dump(points)
    end
  end
  
  def load_cache
    File.open("cached_nav.marshal", "rb") {|f| Marshal.load(f.read)}
  rescue Errno::ENOENT
    parse_and_cache
    retry
  end
end