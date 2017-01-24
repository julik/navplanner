class Leg < Struct.new(:from, :to)
  GREAT_CIRCLE_RADIUS_MILES = 3956
  GREAT_CIRCLE_RADIUS_KILOMETERS = 6371 # some algorithms use 6367
  GREAT_CIRCLE_RADIUS_FEET = GREAT_CIRCLE_RADIUS_MILES * 5280
  GREAT_CIRCLE_RADIUS_METERS = GREAT_CIRCLE_RADIUS_KILOMETERS * 1000
  GREAT_CIRCLE_RADIUS_NAUTICAL_MILES = GREAT_CIRCLE_RADIUS_MILES / 1.15078
      
  def to_s
    "%s -> %s %0.2f° (True), (%d km)" % [from.name, to.name, bearing, dist_km]
  end
  
  def bearing
    @brg ||= Haversine.true_bearing(from, to)
  end

  def inbound_bearing
    @inv_brg ||= Haversine.true_bearing(to, from)
  end
  
  def gc_bearing_from(initial_from)
    conv_angle = Haversine.meridian_convergence_deg(initial_from, from)
    bearing_rel = if bearing > 180
      bearing + conv_angle
    else
      bearing - conv_angle
    end
    Haversine.normalize(bearing_rel)
  end

  def dist_rads
    @dist ||= Haversine.distance(from, to)
  end
  
  def dist_nm
    (dist_rads * GREAT_CIRCLE_RADIUS_NAUTICAL_MILES).round
  end
  
  def dist_km
    (dist_rads * GREAT_CIRCLE_RADIUS_KILOMETERS).round
  end
end