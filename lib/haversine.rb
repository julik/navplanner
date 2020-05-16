module Haversine
  extend self
  
  RAD_PER_DEG = Math::PI / 180
  GREAT_CIRCLE_RADIUS_MILES = 3956
  GREAT_CIRCLE_RADIUS_KILOMETERS = 6371 # some algorithms use 6367
  GREAT_CIRCLE_RADIUS_NAUTICAL_MILES = GREAT_CIRCLE_RADIUS_MILES / 1.15078
  R = GREAT_CIRCLE_RADIUS_NAUTICAL_MILES
  
  def rad_to_nm(dist_rads)
    (dist_rads * GREAT_CIRCLE_RADIUS_NAUTICAL_MILES)
  end
  
  def rad_to_km(dist_rads)
    (dist_rads * GREAT_CIRCLE_RADIUS_KILOMETERS)
  end
  
  # Given two lat/lon points, compute the distance between the two points using the haversine formula,
  # and return the result in radians
  def distance_radians(from, to)
    lat1, lon1 = rpd(from.lat), rpd(from.lon)
    lat2, lon2 = rpd(to.lat), rpd(to.lon)
    
    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = Math.sin(dlat/2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon/2)**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
  end

  def distance_km(from, to)
    distance_radians(from, to) * GREAT_CIRCLE_RADIUS_KILOMETERS
  end
  
  def distance_nm(from, to)
    distance_radians(from, to) * GREAT_CIRCLE_RADIUS_NAUTICAL_MILES
  end
  
  # Radians per degree
  def rpd(num)
    num * RAD_PER_DEG
  end
  
  def dpr(num)
    num / RAD_PER_DEG
  end

  def at_radial_offset(from_pt, bearing_deg, by_dist_nm)
    φ1 = rpd(from_pt.lat)
    λ1 = rpd(from_pt.lon)
    brng = rpd(bearing_deg)
    d = by_dist_nm
    
    φ2 = Math.asin( Math.sin(φ1)*Math.cos(d/R) +
                        Math.cos(φ1)*Math.sin(d/R)*Math.cos(brng))
    λ2 = λ1 + Math.atan2(Math.sin(brng)*Math.sin(d/R)*Math.cos(φ1),
                             Math.cos(d/R)-Math.sin(φ1)*Math.sin(φ2))
                             
    [dpr(φ2), dpr(λ2)]
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
    return 0.0 if distance_nm(from, to) < 0.001
    true_tk_outbound(from, to) - true_tk_inbound(from, to)
  end
   
  def inverse(deg)
    normalize(deg + 180.0)
  end

  def normalize_lon(deg_lon)
    (deg_lon+540) % 360 - 180
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
