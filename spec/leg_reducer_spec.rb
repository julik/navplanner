require 'spec_helper'

describe LegReducer do
  it 'reduces legs' do
    wpts = [
      XPFMSParser::Waypoint.new("UUDD", 594.0, 55.408611, 37.906389),
      XPFMSParser::Waypoint.new("WT", 12300.0, 55.588889, 37.785833),
      XPFMSParser::Waypoint.new("GEKLA", 15000.0, 55.65, 37.868056),
      XPFMSParser::Waypoint.new("DAKLO", 23400.0, 55.616667, 38.631389),
      XPFMSParser::Waypoint.new("SF", 30400.0, 55.548333, 39.996944),
      XPFMSParser::Waypoint.new("GAMDI", 31000.0, 55.666667, 40.614722),
      XPFMSParser::Waypoint.new("CW", 31000.0, 55.867778, 41.784444),
      XPFMSParser::Waypoint.new("USTOK", 31000.0, 56.131667, 43.218056),
      XPFMSParser::Waypoint.new("MASTE", 31000.0, 56.346389, 43.9125),
      XPFMSParser::Waypoint.new("LIBMO", 31000.0, 56.531944, 44.53),
      XPFMSParser::Waypoint.new("GILAM", 31000.0, 56.65, 44.931389),
      XPFMSParser::Waypoint.new("LAMGU", 31000.0, 57.348056, 46.771944),
      XPFMSParser::Waypoint.new("KODUG", 31000.0, 57.498056, 47.392778),
      XPFMSParser::Waypoint.new("LANIL", 31000.0, 57.911667, 49.086389),
      XPFMSParser::Waypoint.new("ABURI", 31000.0, 58.078889, 52.138056),
      XPFMSParser::Waypoint.new("GIMUN", 31000.0, 58.166944, 54.976667),
      XPFMSParser::Waypoint.new("BUMUR", 31000.0, 57.803611, 58.435),
      XPFMSParser::Waypoint.new("ABDIR", 31000.0, 57.521944, 60.606667),
      XPFMSParser::Waypoint.new("NAMOL", 31000.0, 57.636944, 61.796667),
      XPFMSParser::Waypoint.new("AKERA", 31000.0, 57.720278, 62.751944),
      XPFMSParser::Waypoint.new("SALER", 31000.0, 57.828611, 64.138611),
      XPFMSParser::Waypoint.new("ATMES", 31000.0, 57.981944, 65.928611),
      XPFMSParser::Waypoint.new("KULAM", 31000.0, 58.050278, 66.866944),
      XPFMSParser::Waypoint.new("NH", 31000.0, 58.142222, 68.275833),
      XPFMSParser::Waypoint.new("PIRED", 31000.0, 58.096389, 72.547222),
      XPFMSParser::Waypoint.new("MAPID", 31000.0, 57.970556, 75.792222),
      XPFMSParser::Waypoint.new("DILOR", 31000.0, 57.728889, 79.7125),
      XPFMSParser::Waypoint.new("KEPET", 31000.0, 57.648333, 80.506944),
      XPFMSParser::Waypoint.new("POGUT", 31000.0, 57.132222, 84.736111),
      XPFMSParser::Waypoint.new("ADONI", 31000.0, 56.328889, 88.897778),
      XPFMSParser::Waypoint.new("ROTLI", 21900.0, 56.272222, 90.611111),
      XPFMSParser::Waypoint.new("RANET", 16000.0, 56.283889, 91.133056),
      XPFMSParser::Waypoint.new("UNKL", 3400.0, 56.173056, 92.493333),
    ]
    legs = wpts.each_cons(2).map {|(a, b)| Leg.new(a, b) }

    reduced = LegReducer.reduce(legs, delta_deg: 1)
    expect(reduced.length).to eq(19)
 
    reduced = LegReducer.reduce(legs, delta_deg: 5)
    expect(reduced.length).to eq(14)

    reduced = LegReducer.reduce(legs, delta_deg: 15)
    expect(reduced.length).to eq(8)
  end
end
