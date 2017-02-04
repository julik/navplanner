require 'terminal-table'

module PlanPrinter
  extend self
  def print_plan(legs, target=$stdout)
    total_dist_km = legs.map(&:dist_km).inject(&:+)
    total_dist_nm = legs.map(&:dist_nm).inject(&:+)

    target.puts "FPL NOT FOR REAL NAVIGATION"
    target.puts "%s > %s (%d KM / %d NM" % [legs.first.from.ident, legs.last.to.ident, total_dist_km, total_dist_nm]
    
    table = Terminal::Table.new do |t|
      initial_from = legs.first.from
  
      t << %w(
        FROM
        TO
        MD
        TK.OUTB(TRUE)
        BRG.INB(TRUE)
        DIST(KM)
        DIST(NM)
        RADIO
      )
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
          degrees(from.magnetic_variation),
          degrees(leg.outbound_tk),
          degrees(leg.inbound_tk),
          degrees_with_minutes(leg.gc_bearing_from(initial_from)),
          "%0.1f" % leg.dist_km,
          "%0.1f" % leg.dist_nm,
          radio,
          
        ]
      end
    end
    target.puts table
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
