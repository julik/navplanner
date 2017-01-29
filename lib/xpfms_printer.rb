module XPFMSPrinter
  extend self

  def print_plan(legs, beacons, target=$stdout)
    target.puts 'I'
    target.puts '3 version'
    target.puts '1'
    target.puts '1'
    leg_waypoints(legs).each do |wpt|
      print_wpt(wpt, target)
    end
  end
  
  def leg_waypoints(legs)
    [legs[0].from] + legs.map(&:to)
  end
  
  def print_wpt(wpt, target)
    case wpt
    when FIX
      target.puts "11 %s 0 %0.6f %0.6f" % [wpt.ident, wpt.lat, wpt.lon]
    when NDB
      target.puts "2 %s 0 %0.6f %0.6f" % [wpt.ident, wpt.lat, wpt.lon]
    when APT
      target.puts "1 %s 0 %0.6f %0.6f" % [wpt.ident, wpt.lat, wpt.lon]
    when VOR
      target.puts "3 %s 0 %0.6f %0.6f" % [wpt.ident, wpt.lat, wpt.lon]
    end
  end
end
