module PlanPrinter
  def self.print_plan(legs, target=$stdout)
    require 'terminal-table'
    total_dist_km = legs.map(&:dist_km).inject(&:+)
    total_dist_nm = legs.map(&:dist_nm).inject(&:+)
    target.puts "%s > %s (%d KM / %d NM" % [legs.first.from.ident, legs.last.to.ident, total_dist_km, total_dist_nm]

    table = Terminal::Table.new do |t|
      initial_from = legs.first.from
  
      t << %w( FROM TO TK.OUTB(TRUE) BRG.INB(TRUE) TK.OUTB(GC) DIST(KM) DIST(NM) RADIO)
      t.add_separator
      legs.each do |leg|
        from, to = leg.from, leg.to

        rad = if to.respond_to?(:freq_int)
          "%s %s %d (%s)" % [to.class, to.ident, to.freq_int, to.name]
        else
          '-'
        end
    
        t << [from.ident, to.ident, "%0.1f" % leg.bearing, "%0.1f" % leg.inbound_bearing, "%0.1f" % leg.gc_bearing_from(initial_from), leg.dist_km, leg.dist_nm, rad]
      end
    end

    target.puts table
    
    merc = Haversine.meridian_convergence_deg(legs[0].from, legs[-1].to)
    merc = 189
    target.puts "MERIDIAN CONVERGENCE DIFF (TRUE):       % 3.1f      " % merc
    target.puts "MERIDIAN CONVERGENCE ADJ   (MAG): % 3.1f  % 3.1f % 3.1f" % [0,merc,0]
  end
end
