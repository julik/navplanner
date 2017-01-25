class NVUCorrection < Struct.new(:map_angle, :s_km, :z_km)
  def self.compute(leg, beacon)
    # Determine the map angle. It is the same as the inbound (!) bearing of the
    # waypoint plus the meridian convergence angle (true). By taking meridian convergence into
    # account we can then solve this using planar coordinates and angles.
    map_angle = Haversine.rpd(leg.bearing_to + Haversine.meridian_convergence_deg(beacon, leg.to))

    # We will use the leg as a vector from the beacon to the wpt
    diag = Leg.new(beacon, leg.to)
    diag_len_km = diag.dist_km
    rsbn_phi = Haversine.rpd(diag.bearing_from)
    radial_vs_map = map_angle - rsbn_phi
    s_km = Math.cos(radial_vs_map) * diag_len_km * -1
    z_km = Math.sin(radial_vs_map) * diag_len_km
    new(Haversine.dpr(map_angle), s_km, z_km)
  end
end

if __FILE__ == $0
  require 'ostruct'

  #<struct RSBN lat=69.105, lon=32.4267, ident="VA", name="MURMANSK Kilpyavr", chan="25", elev_mtr=93.0>
  beacon = OpenStruct.new
  beacon.lat = 69.105
  beacon.lon = 32.4267

  #<struct FIX lat=70.623054, lon=19.011264, ident="BETMA", name="BETMA">
  from = OpenStruct.new
  from.lat = 70.623054
  from.lon = 19.011264

  # #<struct FIX lat=72.083333, lon=19.7, ident="UVSAS", name="UVSAS">
  to = OpenStruct.new
  to.lat = 72.083333
  to.lon = 19.7
  leg = Leg.new(from, to)
  
  corr = NVUCorrection.compute(leg, beacon)
end
