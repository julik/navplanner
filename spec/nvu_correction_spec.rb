require 'spec_helper'

describe NVUCorrection do
  it 'correctly computes the angles' do
    require 'ostruct'

    #<struct RSBN lat=69.105, lon=32.4267, ident="VA", name="MURMANSK Kilpyavr", chan="25", elev_mtr=93.0>
    beacon = double(lat: 69.105, lon: 32.4267)
    #<struct FIX lat=70.623054, lon=19.011264, ident="BETMA", name="BETMA">
    from = double(lat: 70.623054, lon: 19.011264)
    # #<struct FIX lat=72.083333, lon=19.7, ident="UVSAS", name="UVSAS">
    to = double(lat: 72.083333, lon: 19.7)
    
    leg = Leg.new(from, to)
    corr = NVUCorrection.compute(leg, beacon)

    expect(corr.map_angle).to be_within(0.05).of(20.90599003839904)
    expect(corr.s_km).to be_within(0.05).of(-197.36)
    expect(corr.z_km).to be_within(0.05).of(538.25)
  end
end