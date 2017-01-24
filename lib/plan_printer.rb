require 'terminal-table'

module PlanPrinter
  extend self
  def print_plan(legs, target=$stdout)
    total_dist_km = legs.map(&:dist_km).inject(&:+)
    total_dist_nm = legs.map(&:dist_nm).inject(&:+)
    target.puts "%s > %s (%d KM / %d NM" % [legs.first.from.ident, legs.last.to.ident, total_dist_km, total_dist_nm]
    
    table = Terminal::Table.new do |t|
      initial_from = legs.first.from
  
      t << %w( FROM TO TK.OUTB(TRUE) BRG.INB(TRUE) TK.OUTB(GC) DIST(KM) DIST(NM) RADIO)
      t.add_separator
      legs.each do |leg|
        from, to = leg.from, leg.to

        radio = if to.respond_to?(:freq_int)
          "%s %s %d (%s)" % [to.class, to.ident, to.freq_int, to.name]
        else
          '-'
        end
    
        t << [
          from.ident,
          to.ident,
          degrees_with_minutes(leg.bearing),
          degrees_with_minutes(leg.inbound_bearing),
          degrees_with_minutes(leg.gc_bearing_from(initial_from)),
          leg.dist_km,
          leg.dist_nm,
          radio,
        ]
      end
    end

    first_wpt, last_wpt = legs[0].from, legs[-1].to
    merc = Haversine.meridian_convergence_deg(first_wpt, last_wpt)
    target.puts "MERIDIAN CONVERGENCE DIFF (TRUE):       % 3.1f      " % merc

    m_f = Haversine.magvar_at(first_wpt)
    m_t = Haversine.magvar_at(last_wpt)
    merc_mag = m_f - m_t + merc  
    target.puts "MERIDIAN CONVERGENCE ADJ   (MAG): % 3.1f  % 3.1f % 3.1f" % [m_f,merc_mag,m_t]
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
