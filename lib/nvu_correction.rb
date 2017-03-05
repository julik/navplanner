require_relative 'haversine'
require_relative 'leg'

class NVUCorrection < Struct.new(:beacon, :map_angle, :s_km, :z_km)
  BeaconDist = Struct.new(:beacon, :distance) # A tule of beacon and distance we can use to sort on

  def self.compute_automatically(leg)
    # Parse and load the RSBN file
    loader = ParserLoader.new(__dir__)
    beacons = []
    loader.parse_rsbn(beacons)
    
    distances = beacons.map do |bcn|
      surface_distance = Haversine.rad_to_km(Haversine.distance(leg.to, bcn))
      # We are in a Tu-154 that flies 10K meters above ground.
      # A good idea to take the altitude into account as well.
      # alt_from_beacon = (10100 - bcn.elev_mtr) / 1000.0
      # reception_distance = Math.sqrt(alt_from_beacon ** 2 + surface_distance ** 2)
      BeaconDist.new(bcn, surface_distance)
    end
    
    # Cull all the beacons that are too close or too far
    distances.reject! {|d| d.distance > 300 }
    return if distances.empty?
    
    closest = distances.min_by(&:distance).beacon
    return unless closest
    
    compute(leg, closest)
  end

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
    new(beacon, Haversine.dpr(map_angle), s_km, z_km)
  end
end
