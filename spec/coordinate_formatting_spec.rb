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
      expect(CoordinateFormatting.latitude(lat2)).to eq("S89°19′12″")
    end
    
    it 'does not flip the latitude at poles but uses a modulo' do
      lat1 = 95.56897
      expect(CoordinateFormatting.latitude(lat1)).to eq("N84°25′51″")
      
      lat2 = -128.32
      expect(CoordinateFormatting.latitude(lat2)).to eq("S51°40′47″")
    end
  end

  describe 'longitude' do
    it 'formats latitude north and south' do
      lon1 = 14.56897
      expect(CoordinateFormatting.longitude(lon1)).to eq("E014°34′08″")
      
      lon2 = -89.32
      expect(CoordinateFormatting.longitude(lon2)).to eq("W089°19′11″")
    end
    
    it 'flips the longitude at the international date line' do
      lon1 = 192.56897
      expect(CoordinateFormatting.longitude(lon1)).to eq("W167°25′51″")
      
      lon2 = -192.56897
      expect(CoordinateFormatting.longitude(lon2)).to eq("E167°25′51″")
    end
  end

end
