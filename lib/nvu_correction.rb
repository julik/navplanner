require_relative 'haversine'
require_relative 'leg'

class NVUCorrection < Struct.new(:map_angle, :s_km, :z_km)
  def self.compute(leg, beacon)
    # Determine the map angle. It is the same as the inbound (!) bearing of the
    # waypoint plus the meridian convergence angle (true). By taking meridian convergence into
    # account we can then solve this using planar coordinates and angles.
    map_angle = Haversine.rpd(leg.inbound_tk + Haversine.meridian_convergence_deg(beacon, leg.to))

    # We will use the leg as a vector from the beacon to the wpt
    diag = Leg.new(beacon, leg.to)
    diag_len_km = diag.dist_km
    rsbn_phi = Haversine.rpd(diag.outbound_tk)
    radial_vs_map = map_angle - rsbn_phi
    s_km = Math.cos(radial_vs_map) * diag_len_km * -1
    z_km = Math.sin(radial_vs_map) * diag_len_km
    new(Haversine.dpr(map_angle), s_km, z_km)
  end
end
