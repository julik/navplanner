require 'spec_helper'

describe Leg do
  let(:leg) {
    #<struct FIX lat=70.623054, lon=19.011264, ident="BETMA", name="BETMA">
    from = double(name: 'BETMA', lat: 70.623054, lon: 19.011264)
    # #<struct FIX lat=72.083333, lon=19.7, ident="UVSAS", name="UVSAS">
    to = double(name: 'UVSAS', lat: 72.083333, lon: 19.7)
    Leg.new(from, to)
  }
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
end
