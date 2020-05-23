class XPFMSParser
  class Waypoint < Struct.new(:ident, :altitude_ft, :lat, :lon)
    def elev_km
      (altitude_ft * 0.3048) / 1000
    end
  
    def radio?
      false
    end
  
    def magnetic_variation
      Magvar.variation_at(lat, lon, elev_km, magvar_on_day = Time.utc(2020,1,1))
    end

    def to_ruby
      "#{self.class}.new(#{ident.inspect}, #{altitude_ft.inspect}, #{lat.inspect}, #{lon.inspect})"
    end

    def to_s
      "%s" % [ident]
    end
  end

  def self.parse(io)
    # Get the first line, which has to start with I
    first_line = io.gets.strip
    return if first_line != 'I'

    # Second line specifies the version of the .fms format.
    # Remarkable differences are between 1100 and everything below that
    version_line = io.gets.strip
    if version_line.downcase.start_with?('1100 version')
      parse_fms_11(io)
    elsif version_line.downcase.include?('version')
      parse_fms_10_9(io)
    end
  end

  def self.parse_fms_11(io)
    [].tap do |waypoints|
      io.each_line do |line|
        components = line.strip.split(/\s+/)
        # If the first component is not a digit this is not a waypoint, skip over
        next unless components.first =~ /^\d+$/

        _waypoint_type, waypoint_name, _waypoint_procedure_or_airway, waypoint_altitude, lat, lon = components
        waypoints << Waypoint.new(waypoint_name, waypoint_altitude.to_f, lat.to_f, lon.to_f)
      end
    end
  end
end
