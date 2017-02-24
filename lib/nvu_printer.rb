class NVUPrinter
  include CoordinateFormatting
  
  def print_plan(legs, beacons, target=$stdout)
    target.puts t(:title)

    first_wpt, last_wpt = legs[0].from, legs[-1].to

    median_phi = Haversine.dpr((Haversine.rpd(first_wpt.lat) + Haversine.rpd(last_wpt.lat)) / 2)

    magdec_from = first_wpt.magnetic_variation
    magdec_to = last_wpt.magnetic_variation
    meridian_convergence_angle = Haversine.meridian_convergence_deg(first_wpt, last_wpt)
    fork_magnetic = magdec_from - magdec_to - meridian_convergence_angle
    if fork_magnetic.abs > 180
      fork_magnetic = (fork_magnetic % 180) * (fork_magnetic / fork_magnetic)
    end

    target.puts t(:header) % [median_phi, fork_magnetic, meridian_convergence_angle]
    
    table = Terminal::Table.new do |t|
      initial_from = legs.first.from
  
      t << [
        t(:col_leg),
        t(:col_ozmpu),
        t(:col_dist_km),
        t(:col_rsbn),
        t(:col_rsbn_map_angle),
        t(:col_rsbn_offsets),
        t(:col_radio),
        t(:col_magvar),
      ]
      t.add_separator
      legs.each do |leg|
        from, to = leg.from, leg.to
        gc_bearing = leg.gc_bearing_from(initial_from)
        row = [
          '% 6s %s' % [from.ident, to.ident],
          "%s / %s" % [degrees_with_minutes(Haversine.normalize(gc_bearing - magdec_from)), degrees_with_minutes(Haversine.normalize(gc_bearing - magdec_from - magdec_to))],
          "%0.1f" % leg.dist_km,
        ]
        
        if corr_beacon = find_suitable_correction_beacon_for(leg, beacons)
          corr = NVUCorrection.compute(leg, corr_beacon)
          row += [
            corr_beacon,
            degrees_with_minutes(corr.map_angle),
            "%0.1f / %0.1f" % [corr.z_km, corr.s_km],
          ]
        else
          row += ['-', '-', '- / -']
        end

        radio = to.radio? ? to.to_s : '-'
        row << radio

        row << "%s / %s" % [decimal_degrees(from.magnetic_variation), decimal_degrees(to.magnetic_variation)]

        t << row
      end
    end
    target.puts table
  end
  
  class DW < Struct.new(:beacon, :distance)
  end

  def t(*a)
    I18n.translate(*a, scope: :nvu_printer)
  end

  def find_suitable_correction_beacon_for(leg, beacons)
    distances = beacons.map do |bcn|
      # We are in a Tu-154 that flies 10K meters above ground.
      # A good idea to take the altitude into account as well.
      surface_distance = Haversine.rad_to_km(Haversine.distance(leg.to, bcn))
      alt_from_beacon = (10100 - bcn.elev_mtr) / 1000.0
      reception_distance = Math.sqrt(alt_from_beacon ** 2 + surface_distance ** 2)
      DW.new(bcn, reception_distance)
    end
    
    # Cull all the beacons that are too close or too far
    distances.reject! {|d| d.distance < 20 || d.distance > 500 }
    return if distances.empty?
    
    closest = distances.min_by(&:distance).beacon
  end
end