module Planner
  class UnknownWaypoint < StandardError; end
  
  extend self

  def wyaypoints_to_legs(db, waypoints_from_fms_file)
    # If we have that point in the database - use that, if not use what the .fms provides
    waypoints = waypoints_from_fms_file.map do |wpt|
      closest_fixes = db[wpt.ident]
      close_enough = closest_fixes.find {|fix| Haversine.distance_km(wpt, fix) < 1 }
      close_enough || wpt
    end

    waypoints.each_cons(2).map do |(from_pt, to_pt)|
      Leg.new(from_pt, to_pt)
    end
  end

  def wyaypoint_list_to_legs(db, waypoint_names)
    legs = []
    last_resolved_pt = nil
    waypoint_names.each_cons(2) do |from, to|
      possible_legs = []
      possible_froms = if last_resolved_pt
        [last_resolved_pt]
      else
        db[from]
      end
      possible_tos = db[to]
      
      raise UnknownWaypoint, "Unknown waypoint #{from}" if possible_froms.empty?
      raise UnknownWaypoint, "Unknown waypoint #{to}" if possible_tos.empty?
      
      # Do a lookup on all possible legs with these from/to combinations  
      possible_froms.each do |from_pt|
        possible_tos.each do |to_pt|
          leg = Leg.new(from_pt, to_pt)
          possible_legs << leg 
        end
      end
  
      # Find the shortest leg of the found ones
      shortest_leg = possible_legs.sort! {|a, b| a.dist_rads <=> b.dist_rads }.first
      last_resolved_pt = shortest_leg.to
      legs << shortest_leg
    end
    legs
  end
end
