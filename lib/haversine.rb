module Haversine
  extend self
  
  RAD_PER_DEG = Math::PI / 180
  GREAT_CIRCLE_RADIUS_MILES = 3956
  GREAT_CIRCLE_RADIUS_KILOMETERS = 6371 # some algorithms use 6367
  GREAT_CIRCLE_RADIUS_NAUTICAL_MILES = GREAT_CIRCLE_RADIUS_MILES / 1.15078
  
  def rad_to_nm(dist_rads)
    (dist_rads * GREAT_CIRCLE_RADIUS_NAUTICAL_MILES)
  end
  
  def rad_to_km(dist_rads)
    (dist_rads * GREAT_CIRCLE_RADIUS_KILOMETERS)
  end
  
  # Given two lat/lon points, compute the distance between the two points using the haversine formula,
  # and return the result in radians
  def distance(from, to)
    lat1, lon1 = rpd(from.lat), rpd(from.lon)
    lat2, lon2 = rpd(to.lat), rpd(to.lon)
    
    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = Math.sin(dlat/2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon/2)**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
  end

  # Radians per degree
  def rpd(num)
    num * RAD_PER_DEG
  end
  
  def dpr(num)
    num / RAD_PER_DEG
  end

  def true_tk_outbound(from, to)
    lat1, lon1, lat2, lon2 = rpd(from.lat), rpd(from.lon), rpd(to.lat), rpd(to.lon)
    
    deltaL = lon2 - lon1;
    s = Math.cos(lat2) * Math.sin(deltaL);
    c = (Math.cos(lat1) * Math.sin(lat2)) - (Math.sin(lat1)*Math.cos(lat2)*Math.cos(deltaL))

    # This formula returns quadrant as a SIGN of the result, that is - a bearing of 260
    # will be returned as -100. We account for that.
    deg_pos_or_neg = dpr(Math.atan2(s, c))
    normalize(deg_pos_or_neg)
  end
  alias_method :true_bearing, :true_tk_outbound

  def true_tk_inbound(from, to)
    normalize(inverse(true_tk_outbound(to, from)))
  end
  
  # Gives the meridian convergence angle that has to be added (or subtracted)
  # when moving from the "from" point to the "to" point
  def meridian_convergence_deg(from, to)
    # A slightly less precise way:
    # bearing_diff = (from.lon - to.lon) * Math.sin((Haversine.rpd(from.lat) + Haversine.rpd(to.lat)) / 2)
    true_tk_outbound(from, to) - true_tk_inbound(from, to)
  end
   
  def inverse(deg)
    normalize(deg + 180.0)
  end

  def normalize(deg)
    deg = deg % 360.0
    if deg < 0
      360 + deg
    else
      deg
    end
  end
end
