require 'spec_helper'
require 'fileutils'
require 'tmpdir'
describe Navlister do
  it 'scans the directory and returns files sorted by their size' do
    Dir.mktmpdir do |tmpdir|
      FileUtils.mkdir_p(File.join(tmpdir, 'global nav data'))
      File.open(File.join(tmpdir, 'global nav data', 'apt.dat'), 'wb') do |f|
        f << 'very long nav data'
      end
      File.open(File.join(tmpdir, 'global nav data', 'earth_nav.dat'), 'wb') do |f|
        f << 'very long nav data'
      end
      File.open(File.join(tmpdir, 'global nav data', 'earth_awy.dat'), 'wb') do |f|
        f << 'very long nav data'
      end
      File.open(File.join(tmpdir, 'global nav data', 'earth_fix.dat'), 'wb') do |f|
        f << 'very long nav data'
      end

      FileUtils.mkdir_p(File.join(tmpdir, 'AAAA Some Airport'))
      File.open(File.join(tmpdir, 'AAAA Some Airport', 'apt.dat'), 'wb') do |f|
        f << 'tiny'
      end
      
      lister = Navlister.new(tmpdir)
      detected = lister.detect
      
      expect(detected.airport_files.length).to eq(2)
      detected.airport_files.each do |f|
        pth = f.path
        expect(File).to be_exist(pth)
      end

      expect(detected.airway_files.length).to eq(1)
      detected.airway_files.each do |f|
        pth = f.path
        expect(File).to be_exist(pth)
      end

      expect(detected.navaid_files.length).to be > 0
      detected.navaid_files.each do |f|
        pth = f.path
        expect(File).to be_exist(pth)
      end

      expect(detected.fix_files.length).to be > 0
      detected.fix_files.each do |f|
        pth = f.path
        expect(File).to be_exist(pth)
      end
      
      fp = detected.fingerprint
      expect(fp).to be_kind_of(String)
      expect(fp).not_to be_empty
      10.times do 
        expect(detected.fingerprint).to eq(fp)
      end
    end
  end
  
  it 'finds the files in the test directory' do
    td = File.join(__dir__, 'test_xp_data_20170129')

    lister = Navlister.new(td)
    detected = lister.detect
#    expect(detected.airport_files).not_to be_empty
    expect(detected.airway_files).not_to be_empty
    expect(detected.navaid_files).not_to be_empty
    expect(detected.fix_files).not_to be_empty
    
    fp = detected.fingerprint
    expect(fp).to be_kind_of(String)
    expect(fp).not_to be_empty
    10.times do 
      expect(detected.fingerprint).to eq(fp)
    end
  end
end