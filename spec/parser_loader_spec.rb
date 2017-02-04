require 'spec_helper'

describe ParserLoader do
  before :each do
    Dir.glob('./**/*.marshal').each do |p|
      File.unlink(p)
    end
  end
  
  it 'parses a complete nav data set as offered by X-Plane.com' do
    loader = ParserLoader.new(__dir__ + '/test_xp_data_20170129')
    points_arr = loader.load_cache
    expect(points_arr.length).to be > 140_000
    db = NavDB.new(points_arr)
    murmansk_ndb = db['RD'].find{|e| e.to_s =~ /murm/i }
    
    expect(murmansk_ndb).to be_kind_of(NDB)
    expect(murmansk_ndb.lat).to be_within(0.05).of(68.743333)
    expect(murmansk_ndb.lon).to be_within(0.05).of(32.818333)
    expect(murmansk_ndb.freq_int).to eq(635)
  end
end
