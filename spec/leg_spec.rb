require 'spec_helper'

describe Leg do
  let(:leg) {
    #<struct FIX lat=70.623054, lon=19.011264, ident="BETMA", name="BETMA">
    from = double(name: 'BETMA', lat: 70.623054, lon: 19.011264)
    # #<struct FIX lat=72.083333, lon=19.7, ident="UVSAS", name="UVSAS">
    to = double(name: 'UVSAS', lat: 72.083333, lon: 19.7)
    Leg.new(from, to)
  }

  it 'combines multiple legs and adds abeam points' do
    pt1 = double(name: 'BETMA', lat: 70.623054, lon: 19.011264)
    pt2 = double(name: 'UVSAS', lat: 72.083333, lon: 19.7)
    pt3 = double(name: 'TODAD', lat: 74.083333, lon: 28.3)
    pt4 = double(name: 'UVSAS', lat: 76.124, lon: 32.1)

    combined = Leg.combined(Leg.new(pt1, pt2), Leg.new(pt2, pt3), Leg.new(pt3, pt4))

    expect(combined.from).to eq(pt1)
    expect(combined.to).to eq(pt4)
    expect(combined.abeams).to eq([pt2, pt3])
  end

  it 'computes the distance in rads' do
    expect(leg.dist_rads).to be_within(0.00000001).of(0.02577441675)
  end
  
  it 'computes the outbound track from departure point' do
    expect(leg.outbound_tk).to be_within(0.01).of(8.249672361301773)
  end

  it 'computes the inbound track to arrival point' do
    expect(leg.inbound_tk).to be_within(0.01).of(8.902308698649506)
  end

  it 'computes meridian convergence' do
    expect(leg.meridian_convergence_deg).to be_within(0.01).of(-0.652)
  end
  
  it 'provides a usable to_s' do
    string_repr = leg.to_s
    expect(string_repr).to eq("BETMA -> UVSAS 8.25° (True), (164 km)")
  end
  
  it '#gc_bearing_from computes a relative great circle inbound bearing' do
    magadan = double(lat: 59.910989, lon: 150.7204385)
    mebar = double(lat: 60.266667, lon: 151.816667)
    sesin = double(lat: 63.371667, lon: 165.451111)
    
    leg = Leg.new(magadan, mebar)
    expect(leg.inbound_tk).to be_within(0.01).of(57.4255)
    expect(leg.gc_bearing_from(magadan)).to be_within(0.01).of(56.4752)

    leg = Leg.new(mebar, sesin)
    expect(leg.inbound_tk).to be_within(0.01).of(70.3819)
    expect(leg.gc_bearing_from(magadan)).to be_within(0.01).of(57.3971)
  end
end
