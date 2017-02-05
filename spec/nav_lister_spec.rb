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
      detected.apt_files.each do |f|
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
        
    end
  end
end