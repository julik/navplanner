require 'spec_helper'

describe XPFMSParser do
  it 'parses waypoints from X-Plane FMS format v.11' do
    path = File.join(__dir__, 'xpfms_flightplan_examples', 'UUDDUHMA01_XP11.fms')

    waypoints = File.open(path, "rb") do |fi|
      XPFMSParser.parse(fi)
    end
  end

  it 'parses waypoints from X-Plane FMS format v.10'
end
