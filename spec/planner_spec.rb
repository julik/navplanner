require 'spec_helper'

describe Planner do
  it 'parses the example flight plan' do

    loader = ParserLoader.new(__dir__ + '/test_xp_data_20170129')
    points_arr = loader.load_cache
    db = NavDB.new(points_arr)

    waypoint_names = %w( ULMM RD PELOR KELEK ADEXU ENEXI ATA BETMA UVSAS EDIKI OTVIK AMPIS LON ENSB )
    
    legs = Planner.wyaypoint_list_to_legs(db, waypoint_names)
    
    expect(legs.length).to eq(13)
    
    legs.each do | leg |
      expect(leg.dist_km).to be < 1000
      expect(leg.dist_km).to be > 1
    end
    
    total_distance = legs.map(&:dist_km).inject(&:+)
    expect(total_distance).to be_within(10).of(1505)

    expect(legs.first.from.ident).to eq('ULMM')
    expect(legs.last.to.ident).to eq('ENSB')
  end
  
  it 'maps out a transpolar route'
  it 'maps out a trans-equatorial route'
  it 'maps out a route across the international dateline'
end
