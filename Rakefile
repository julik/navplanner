require 'rake/clean'
require 'rake/extensiontask'
require 'rspec/core/rake_task'
require 'bundler'

Rake::ExtensionTask.new do |ext|
  ext.name = 'magvar'           # indicate the name of the extension.
  ext.ext_dir = 'ext'         # search for 'hello_world' inside it.
  ext.lib_dir = 'lib'         # put binaries into this folder.
end

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w( --colour --format progress )
  t.pattern = 'spec/**/*_spec.rb'
end

desc 'Unpack gzipped apt.dat'
task :unpack_apt_dat do
  `cd spec/test_xp_data_20170129 && gunzip apt.dat.gz`
end

task :spec => [:compile, :unpack_apt_dat]
task :default => :spec
