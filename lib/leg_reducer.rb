module LegReducer
  def self.reduce(legs, delta_deg: 5)
    first_wpt = legs[0].from

    # The first group will be the first leg
    reduced = [legs.first]

    # and then we can reduce
    legs[1..-1].each do |leg|
      bearing_delta_deg = reduced.last.gc_bearing_from(first_wpt) - leg.gc_bearing_from(first_wpt)
      if bearing_delta_deg.abs < delta_deg.to_i # legs can be collapsed into one
        reduced << Leg.combined(reduced.pop, leg)
      else # the track angle change is significant, preserve
        reduced << leg
      end
    end

    reduced
  end
end
