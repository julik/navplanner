module Planner
  class UnknownWaypoint < StandardError; end
  
  extend self
  def wyaypoint_list_to_legs(db, waypoint_names)
    legs = []
    last_resolved_pt = nil
    each_pair(waypoint_names) do |from, to|
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
  
  private
  
  def each_pair(of_arr)
    return if of_arr.length < 2
    (0..(of_arr.length - 2)).each do |si|
      yield(of_arr[si], of_arr[si+1])
    end
  end
end
