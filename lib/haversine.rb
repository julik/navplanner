module Haversine
  RAD_PER_DEG = Math::PI / 180
  # given two lat/lon points, compute the distance between the two points using the haversine formula
  def self.distance(from, to)
    lat1, lon1 = from.lat, from.lon
    lat2, lon2 = to.lat, to.lon
    
    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = (Math.sin(rpd(dlat)/2))**2 + Math.cos(rpd(lat1)) * Math.cos((rpd(lat2))) * (Math.sin(rpd(dlon)/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
  end

  # Radians per degree
  def self.rpd(num)
    num * RAD_PER_DEG
  end
  
  def self.dpr(num)
    num / RAD_PER_DEG
  end
  
  def self.magvar_at(pt)
    magvar_rads = Magvar.magvar(rpd(pt.lat), rpd(pt.lon), Time.utc(2020,1,1), 0)
    dpr(magvar_rads)
  end
  
  def self.true_bearing(from, to)
    lat1, lon1, lat2, lon2 = rpd(from.lat), rpd(from.lon), rpd(to.lat), rpd(to.lon)
    
    deltaL = lon2 - lon1;
    s = Math.cos(lat2) * Math.sin(deltaL);
    c = (Math.cos(lat1) * Math.sin(lat2)) - (Math.sin(lat1)*Math.cos(lat2)*Math.cos(deltaL))

    # This formula returns quadrant as a SIGN of the result, that is - a bearing of 260
    # will be returned as -100. We account for that.
    deg_pos_or_neg = dpr(Math.atan2(s, c))
    if deg_pos_or_neg < 0
      deg_pos_or_neg = 360.0 + deg_pos_or_neg
    end
    deg_pos_or_neg
  end
  
  # Gives the meridian convergence angle that has to be added (or subtracted)
  # when moving from the "from" point to the "to" point
  def self.meridian_convergence_deg(from, to)
    bearing = true_bearing(from, to)
    bearing_diff = (from.lon - to.lon) * Math.sin((Haversine.rpd(from.lat) + Haversine.rpd(to.lat)) / 2)
  end
   
  def self.inverse(deg)
    normalize(deg + 180.0)
  end

  def self.normalize(deg)
    deg = deg % 360.0
    if deg < 0
      360 + deg
    else
      deg
    end
  end
end
