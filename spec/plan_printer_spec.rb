require 'spec_helper'

describe PlanPrinter do
  it 'prints a predefined flight plan' do
    wpts = []
    wpts << APT.new(lat=68.781751845, lon=32.752029995, ident="ULMM", name="Murmansk")
    wpts << NDB.new(lat=68.743333, lon=32.818333, ident="RD", name="MURMANSK NDB", elev_ft=0.0, freq_int=635, reception_range_nm=80.0)
    wpts << FIX.new(lat=68.616667, lon=31.78, ident="PELOR", name="PELOR")
    wpts << FIX.new(lat=68.503333, lon=28.458333, ident="KELEK", name="KELEK")
    wpts << FIX.new(lat=68.770833, lon=27.619722, ident="ADEXU", name="ADEXU")
    wpts << FIX.new(lat=69.330833, lon=25.752778, ident="ENEXI", name="ENEXI")
    wpts << DME.new(lat=69.977581, lon=23.371817, ident="ATA", name="ALTA VOR/DME", elev_ft=32.0, freq_int=11740, nm_dme_bias=0.0)
    wpts << FIX.new(lat=70.623054, lon=19.011264, ident="BETMA", name="BETMA")
    wpts << FIX.new(lat=72.083333, lon=19.7, ident="UVSAS", name="UVSAS")
    wpts << FIX.new(lat=76.445833, lon=18.398667, ident="EDIKI", name="EDIKI")
    wpts << FIX.new(lat=77.266667, lon=18.043333, ident="OTVIK", name="OTVIK")
    wpts << FIX.new(lat=77.957972, lon=17.718306, ident="AMPIS", name="AMPIS")
    wpts << NDB.new(lat=78.249733, lon=15.401211, ident="LON", name="LONGYEAR NDB", elev_ft=10.0, freq_int=350, reception_range_nm=25.0)
    wpts << APT.new(lat=78.24622447, lon=15.46383676, ident="ENSB", name="Svalbard Longyear")
    
    each_pair = ->(of_arr, &blk) {
      return if of_arr.length < 2
      (0..(of_arr.length - 2)).each do |si|
        blk.call(of_arr[si], of_arr[si+1])
      end
    }
    
    legs = []
    each_pair.call(wpts) do |from, to|
      legs << Leg.new(from, to)
    end
    out = StringIO.new
    PlanPrinter.print_plan(legs, out)
    puts out.string
  end
end
