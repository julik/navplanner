require 'spec_helper'

describe CoordinateFormatting do
  describe 'decimal_degrees' do
    it 'converts neg. degrees to positive' do
      expect(CoordinateFormatting.decimal_degrees(-10)).to eq('350.0°')
    end
  end

  describe 'degrees_with_minutes' do
    it 'converts neg. degrees to positive' do
      expect(CoordinateFormatting.degrees_with_minutes(-10.3)).to eq('349°42′')
    end
  end
  
  describe 'latitude' do
    it 'formats latitude north and south' do
      lat1 = 14.56897
      expect(CoordinateFormatting.latitude(lat1)).to eq("N14°34′08″")
      
      lat2 = -89.32
      expect(CoordinateFormatting.latitude(lat2)).to eq("S89°19′11″")
    end
  end

  describe 'longitude' do
    it 'formats latitude north and south' do
      lon1 = 14.56897
      expect(CoordinateFormatting.longitude(lon1)).to eq("E014°34′08″")
      
      lon2 = -89.32
      expect(CoordinateFormatting.longitude(lon2)).to eq("W089°19′11″")
    end
  end

end
