require 'spec_helper'

describe XPFMSParser do
  it 'parses waypoints from X-Plane FMS format v.11' do
    path = File.join(__dir__, 'xpfms_flightplan_examples', 'UUDDUNKL01.fms')

    waypoints = File.open(path, "rb") do |fi|
      XPFMSParser.parse(fi)
    end
    
    waypoints.each do |wpt|
      puts wpt.to_ruby
    end
  end

  it 'parses waypoints from X-Plane FMS format v.10'
end
