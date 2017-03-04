require 'rake/clean'
require 'rspec/core/rake_task'
require 'bundler'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w( --colour --format progress )
  t.pattern = 'spec/**/*_spec.rb'
end

desc 'Unpack gzipped apt.dat'
task :unpack_apt_dat do
  `cd spec/test_xp_data_20170129 && gunzip apt.dat.gz`
end

task :spec => [:unpack_apt_dat]
task :default => :spec
