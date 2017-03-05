require 'spec_helper'

describe Haversine do
  describe '.distance - distance in radians' do
    it 'computes the correct distance' do
      murmansk = double(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      provideniya = double(lat: 64.3654753675, lon: -173.23902230750002, ident: 'UHMA')
      dist_rad = Haversine.distance(murmansk, provideniya)
      expect(dist_rad).to be_within(0.01).of(0.795)
      
      svalbard = double(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
      dist_rad = Haversine.distance(murmansk, svalbard)
      expect(dist_rad).to be_within(0.01).of(0.184)
    end
  end
  
  describe '.distance_km' do
    it 'computes in kilometers' do
      murmansk = double(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      svalbard = double(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
    
      dist_km = Haversine.distance_km(murmansk, svalbard)
      expect(dist_km).to be_within(0.05).of(1174.446)
    end
  end

  describe '.distance_nm' do
    it 'computes in nautical miles' do
      murmansk = double(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      svalbard = double(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
    
      dist_nm = Haversine.distance_nm(murmansk, svalbard)
      expect(dist_nm).to be_within(0.05).of(633.708)
    end
  end
  
  describe 'at_radial_offset(from_pt, bearing_deg, by_dist_nm)' do
    it 'computes the same location, to the dot' do
      murmansk = double(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      svalbard = double(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
    
      dist_nm = Haversine.distance_nm(murmansk, svalbard)
      expect(dist_nm).to be_within(0.05).of(633.70)

      brg_deg = Haversine.true_tk_outbound(murmansk, svalbard)
      expect(brg_deg).to be_within(0.05).of(340.71)
    
      offset_lat, offset_lon = Haversine.at_radial_offset(murmansk, brg_deg, dist_nm)
      expect(offset_lat).to be_within(0.00005).of(svalbard.lat)
      expect(offset_lon).to be_within(0.00005).of(svalbard.lon)
    end
    
    it 'computes the same location when negative angles are used' do
      murmansk = double(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      svalbard = double(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
    
      dist_nm = Haversine.distance_nm(murmansk, svalbard)
      expect(dist_nm).to be_within(0.05).of(633.70)

      brg_deg = Haversine.true_tk_outbound(murmansk, svalbard)
      brg_deg -= 360
      expect(brg_deg).to be_within(0.05).of(-19.284)
    
      offset_lat, offset_lon = Haversine.at_radial_offset(murmansk, brg_deg, dist_nm)
      expect(offset_lat).to be_within(0.00005).of(svalbard.lat)
      expect(offset_lon).to be_within(0.00005).of(svalbard.lon)
    end
  end
  
  describe '.true_tk_inbound and .true_tk_outbound - true tracks and meridian convergence angle' do
    it 'returns meridian convergence angle of 0 for very small distances' do
      magadan = double(lat: 59.910989, lon: 150.7204385)
      expect(Haversine.meridian_convergence_deg(magadan, magadan)).to be_within(0.1).of(0)
    end
    
    it 'computes transpolar' do
      murmansk = double(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      provideniya = double(lat: 64.3654753675, lon: -173.23902230750002, ident: 'UHMA')
      tk_out = Haversine.true_tk_outbound(murmansk, provideniya)
      expect(tk_out).to be_within(0.05).of(15.38)
      
      tk_in = Haversine.true_tk_inbound(murmansk, provideniya)
      expect(tk_in).to be_within(0.05).of(167.17)
      
      merc = Haversine.meridian_convergence_deg(murmansk, provideniya)
      expect(merc).to be_within(0.05).of(-151.78)
    end
    
    it 'computes E' do
      murmansk = double(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      svalbard = double(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
      
      tk_out = Haversine.true_tk_outbound(murmansk, svalbard)
      expect(tk_out).to be_within(0.05).of(340.71)
      
      tk_in = Haversine.true_tk_inbound(murmansk, svalbard)
      expect(tk_in).to be_within(0.05).of(324.071)
      
      merc = Haversine.meridian_convergence_deg(murmansk, svalbard)
      expect(merc).to be_within(0.05).of(16.64)
    end

    it 'computes W' do
      murmansk = double(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      svalbard = double(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
      
      tk_out = Haversine.true_tk_outbound(svalbard, murmansk)
      expect(tk_out).to be_within(0.05).of(144.07)
      
      tk_in = Haversine.true_tk_inbound(svalbard, murmansk)
      expect(tk_in).to be_within(0.05).of(160.71)
      
      merc = Haversine.meridian_convergence_deg(svalbard, murmansk)
      expect(merc).to be_within(0.05).of(-16.64)
    end
    
    it 'computes E when crossing the international date line' do
      anadyr = double(lat: 64.734956445, lon: 177.74154393999999, ident: 'UHMA')
      provideniya = double(lat: 64.3654753675, lon: -173.23902230750002, ident: 'UHMA')

      tk_out = Haversine.true_tk_outbound(anadyr, provideniya)
      expect(tk_out).to be_within(0.05).of(91.36)
      
      tk_in = Haversine.true_tk_inbound(anadyr, provideniya)
      expect(tk_in).to be_within(0.05).of(99.50)

      merc = Haversine.meridian_convergence_deg(anadyr, provideniya)
      expect(merc).to be_within(0.05).of(-8.147)
    end
    
    it 'computes W when crossing the international date line' do
      anadyr = double(lat: 64.734956445, lon: 177.74154393999999, ident: 'UHMA')
      provideniya = double(lat: 64.3654753675, lon: -173.23902230750002, ident: 'UHMA')

      tk_out = Haversine.true_tk_outbound(provideniya, anadyr)
      expect(tk_out).to be_within(0.05).of(279.50)
      
      tk_in = Haversine.true_tk_inbound(provideniya, anadyr)
      expect(tk_in).to be_within(0.05).of(271.36)

      merc = Haversine.meridian_convergence_deg(provideniya, anadyr)
      expect(merc).to be_within(0.05).of(8.147)
    end
  end
end
