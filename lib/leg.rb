class Leg < Struct.new(:from, :to)
  def to_s
    "%s -> %s %0.2f° (True), (%d km)" % [from.name, to.name, outbound_tk, dist_km]
  end
  
  def outbound_tk
    @brg ||= Haversine.true_bearing(from, to)
  end
  
  def inbound_tk
    @inv_brg ||= Haversine.inverse(Haversine.true_bearing(to, from))
  end
  
  def gc_bearing_from(initial_from)
    conv_angle = Haversine.meridian_convergence_deg(initial_from, from)
    bearing_from = outbound_tk
    bearing_rel = if bearing_from > 180
      bearing_from + conv_angle
    else
      bearing_from - conv_angle
    end
    Haversine.normalize(bearing_rel)
  end

  def meridian_convergence_deg
    Haversine.meridian_convergence_deg(from, to)
  end

  def dist_rads
    @dist ||= Haversine.distance(from, to)
  end
  
  def dist_nm
    Haversine.rad_to_nm(dist_rads)
  end
  
  def dist_km
    Haversine.rad_to_km(dist_rads)
  end
end