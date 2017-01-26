module NVUPrinter
  extend self
  def print_plan(legs, beacons, target=$stdout)
    target.puts "NVU WAYPOINT LIST"
    
    table = Terminal::Table.new do |t|
      initial_from = legs.first.from
  
      t << %w(
        FROM
        TO
        MD
        OZPU(T)
        DIST(KM)
        RSBN\ CORRECTION\ BCN
        MAP\ ANGLE
        Sm/Zm
        RADIO
      )
      t.add_separator
      legs.each do |leg|
        from, to = leg.from, leg.to

        row = [
          from.ident,
          to.ident,
          degrees(from.magnetic_variation),
          degrees_with_minutes(leg.gc_bearing_from(initial_from)),
          "%0.1f" % leg.dist_km,
        ]
        
        if corr_beacon = find_suitable_correction_beacon_for(leg, beacons)
          corr = NVUCorrection.compute(leg, corr_beacon)
          row += [
            corr_beacon,
            degrees_with_minutes(corr.map_angle),
            "%0.1f/%0.1f" % [corr.s_km, corr.z_km],
          ]
        else
          row += ['-', '-', '-/-']
        end

        radio = to.radio? ? to.to_s : '-'
        row << radio

        t << row
      end
    end
    target.puts table
    
    first_wpt, last_wpt = legs[0].from, legs[-1].to
    merc = Haversine.meridian_convergence_deg(first_wpt, last_wpt)
    target.puts "MERIDIAN CONVERGENCE DIFF (TRUE) :       % 3.1f      " % merc

    m_f = first_wpt.magnetic_variation
    m_t = last_wpt.magnetic_variation
    merc_mag = m_f - m_t + merc  
    target.puts "MAGNETIC CONVERGENCE (Mf/FORK/Mt): % 3.1f  % 3.1f % 3.1f" % [m_f,merc_mag,m_t]
  end
  
  class DW < Struct.new(:beacon, :distance)
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
    distances.reject! {|d| d.distance < 50 || d.distance > 600 }
    return if distances.empty?
    
    closest = distances.min_by(&:distance).beacon
  end

  def degrees(degrees)
    "%03.1f°" % [degrees]
  end

  def degrees_with_minutes(degrees)
    whole, fraction = degrees.divmod(1)
    minutes = (fraction * 60).to_i
    "%03d° %02d'" % [whole, minutes]
  end
end