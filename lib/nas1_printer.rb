class NAS1Printer
  include CoordinateFormatting
  
  def print_plan(legs, target=$stdout)
    target.puts t(:title)
    
    first_wpt, last_wpt = legs[0].from, legs[-1].to
    starting_phi = first_wpt.lat
    magdec_from = first_wpt.magnetic_variation
    magdec_to = last_wpt.magnetic_variation
    meridian_convergence_angle = Haversine.meridian_convergence_deg(first_wpt, last_wpt)
    fork_magnetic = magdec_from - magdec_to - meridian_convergence_angle
    if fork_magnetic.abs > 180
      fork_magnetic = (fork_magnetic % 180) * (fork_magnetic / fork_magnetic)
    end

    target.puts t(:header) % [starting_phi, fork_magnetic, meridian_convergence_angle]
    
    table = Terminal::Table.new do |t|
      initial_from = legs.first.from
  
      t << [
        t(:col_leg),
        t(:col_map_angle),
        t(:col_dist_km),
        t(:col_radio),
        t(:col_magvar),
      ]
      t.add_separator
      legs.each do |leg|
        from, to = leg.from, leg.to
        gc_bearing = leg.gc_bearing_from(initial_from)
        row = [
          '% 6s %s' % [from.ident, to.ident],
          degrees_with_minutes(Haversine.normalize(gc_bearing - magdec_from)),
          "%0.1f" % leg.dist_km,
        ]

        radio = to.radio? ? to.to_s : '-'
        row << radio

        row << "%0.1f / %0.1f" % [from.magnetic_variation, to.magnetic_variation]

        t << row
      end
    end
    target.puts table
  end
  
  class DW < Struct.new(:beacon, :distance)
  end

  def t(*a)
    I18n.translate(*a, scope: :nas1_printer)
  end
end