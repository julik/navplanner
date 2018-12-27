require 'logger'

class ParserLoader
  # Make sure we interpret files we parse as UTF-8
  FILE_OPEN_MODE_READ_UTF8 = "r:UTF-8"

  def initialize(path_to_xplane_dir, logger=Logger.new($stderr))
    @logger = logger
    @lister = Navlister.new(path_to_xplane_dir)
  end

  def parse_rsbn(points)
    nav_dat = File.join(__dir__, 'rsbn.dat')
    File.open(nav_dat, FILE_OPEN_MODE_READ_UTF8) do |f|
      @logger.info { "Parsing %s" % nav_dat }
      pts_before = points.length
      f.each_line do |line|
        next if line.strip.empty?
        chan, name, ident, _, lat, lon, elev_mtr = line.strip.split('|')
        beacon = RSBN.new(lat.to_f, lon.to_f, ident, name, chan, elev_mtr.to_f)
        points << beacon
      end
      @logger.info { "Loaded %d items" % (points.length - pts_before) }
    end
  end

  def parse_navaids(points)
    @detected ||= @lister.detect
    @detected.navaid_files.each do |f|
      File.open(f.path, FILE_OPEN_MODE_READ_UTF8) do |f|
        @logger.info { "Parsing %s" % f.path }
        
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
  end
  
  def parse_fixes(points)
    @detected ||= @lister.detect
    @detected.fix_files.each do |f|
      @logger.info { "Parsing %s" % f.path }
      File.open(f.path, FILE_OPEN_MODE_READ_UTF8) do |f|
        3.times { f.gets }
        while line = f.gets
          break if line.strip == '99'
          lat, lon, name = line.strip.split(/\s+/)
          points << FIX.new(lat.to_f, lon.to_f, name, name)
        end
      end
    end
  end
  
  def parse_airports(points)
    @detected ||= @lister.detect
    @detected.airport_files.each do |f|
      @logger.info { "Parsing %s" % f.path }
      File.open(f.path, FILE_OPEN_MODE_READ_UTF8) do |f|
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
                @logger.warn { "No runways defined for #{last_apt.inspect}" }
              end
              defining_lats = []
              defining_lons = []
            end
            apt_id = parts[4]
            apt_name = parts[5..-1].join(' ')
            last_apt = APT.new(0.0, 0.0, apt_id, apt_name)
          end
          if parts[0] == '100'
            # Runway, formatted like "100 30.48 1 0 0.25 0 2 0 12  41.25261908 -072.03575022    0   69 2 0 0 1 30  41.25141173 -072.02738496    0   71 2 0 0 1"
            defining_lats << parts[9].to_f
            defining_lons << parts[10].to_f
            defining_lats << parts[18].to_f
            defining_lons << parts[19].to_f
          end
        end
      end
    end
  end

  def parse_points_from_all_files
    points_queue = Queue.new
    parser_threads = [
      Thread.new { parse_navaids(points_queue) },
      Thread.new { parse_fixes(points_queue) },
      Thread.new { parse_airports(points_queue) },
      Thread.new { parse_rsbn(points_queue) },
    ]
    parser_threads.map(&:join)
    _points = points_queue.length.times.map { points_queue.pop }
  end

  def parse_and_cache
    points = parse_points_from_all_files
    @logger.info { "Found %d navaids, fixes and airports" % points.length }
    marshaled_path = File.expand_path("cached_nav.marshal")
    File.open(marshaled_path, "wb") do |f|
      f << Marshal.dump(points)
    end
    @logger.info { "Written #{points.length} airports, navaids and fixes to #{marshaled_path}" }
  end
  
  def load_cache
    marshaled_path = File.expand_path("cached_nav.marshal")
    data = File.open(marshaled_path, "rb") {|f| Marshal.load(f.read)}
    @logger.info {"Loaded #{data.length} airports, navaids and fixes from #{marshaled_path}"}
    data
  rescue Errno::ENOENT
    parse_and_cache
    retry
  end
end