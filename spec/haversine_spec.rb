require 'spec_helper'

describe Haversine do
  describe 'true tracks and meridian convergence angle' do
    it 'computes transpolar' do
      murmansk = OpenStruct.new(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      provideniya = OpenStruct.new(lat: 64.3654753675, lon: -173.23902230750002, ident: 'UHMA')
      tk_out = Haversine.true_tk_outbound(murmansk, provideniya)
      expect(tk_out).to be_within(0.05).of(15.38)
      
      tk_in = Haversine.true_tk_inbound(murmansk, provideniya)
      expect(tk_in).to be_within(0.05).of(167.17)
      
      merc = Haversine.meridian_convergence_deg(murmansk, provideniya)
      expect(merc).to be_within(0.05).of(-151.78)
    end
    
    it 'computes E' do
      murmansk = OpenStruct.new(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      svalbard = OpenStruct.new(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
      
      tk_out = Haversine.true_tk_outbound(murmansk, svalbard)
      expect(tk_out).to be_within(0.05).of(340.71)
      
      tk_in = Haversine.true_tk_inbound(murmansk, svalbard)
      expect(tk_in).to be_within(0.05).of(324.071)
      
      merc = Haversine.meridian_convergence_deg(murmansk, svalbard)
      expect(merc).to be_within(0.05).of(16.64)
    end

    it 'computes W' do
      murmansk = OpenStruct.new(lat: 68.781751845, lon: 32.752029995, ident: "ULMM")
      svalbard = OpenStruct.new(lat: 78.24622447, lon: 15.46383676, ident: "ENSB", name: "Svalbard Longyear")
      
      tk_out = Haversine.true_tk_outbound(svalbard, murmansk)
      expect(tk_out).to be_within(0.05).of(144.07)
      
      tk_in = Haversine.true_tk_inbound(svalbard, murmansk)
      expect(tk_in).to be_within(0.05).of(160.71)
      
      merc = Haversine.meridian_convergence_deg(svalbard, murmansk)
      expect(merc).to be_within(0.05).of(-16.64)
    end
    
    it 'computes E when crossing the international date line' do
      anadyr = OpenStruct.new(lat: 64.734956445, lon: 177.74154393999999, ident: 'UHMA')
      provideniya = OpenStruct.new(lat: 64.3654753675, lon: -173.23902230750002, ident: 'UHMA')

      tk_out = Haversine.true_tk_outbound(anadyr, provideniya)
      expect(tk_out).to be_within(0.05).of(91.36)
      
      tk_in = Haversine.true_tk_inbound(anadyr, provideniya)
      expect(tk_in).to be_within(0.05).of(99.50)

      merc = Haversine.meridian_convergence_deg(anadyr, provideniya)
      expect(merc).to be_within(0.05).of(-8.147)
    end
    
    it 'computes W when crossing the international date line' do
      anadyr = OpenStruct.new(lat: 64.734956445, lon: 177.74154393999999, ident: 'UHMA')
      provideniya = OpenStruct.new(lat: 64.3654753675, lon: -173.23902230750002, ident: 'UHMA')

      tk_out = Haversine.true_tk_outbound(provideniya, anadyr)
      expect(tk_out).to be_within(0.05).of(279.50)
      
      tk_in = Haversine.true_tk_inbound(provideniya, anadyr)
      expect(tk_in).to be_within(0.05).of(271.36)

      merc = Haversine.meridian_convergence_deg(provideniya, anadyr)
      expect(merc).to be_within(0.05).of(8.147)
    end
  end
end
