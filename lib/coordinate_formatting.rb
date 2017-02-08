module CoordinateFormatting
  extend self
  
  def decimal_degrees(degrees_float)
    if degrees_float < 0
      degrees_float += 360.0
    end
    "%03.1f°" % [degrees_float]
  end
  
  # For headings and NVU entry
  def degrees_with_minutes(degrees_float)
    if degrees_float < 0
      degrees_float += 360.0
    end
    degrees = degrees_float.floor
    minutes = (60 * (degrees_float - degrees)).round
    
    '%03d°%02d′' % [degrees, minutes]
  end
  
  def longitude(degrees_float)
    degrees_float = normalize_latlon(degrees_float, 180)
    pole = degrees_float < 0 ? :W : :E
    whole, minutes, seconds = degree_fractions(degrees_float.abs)
    '%s%03d°%02d′%02d″' % [pole, whole, minutes, seconds]
  end
  
  def latitude(degrees_float)
    degrees_float = normalize_latlon(degrees_float, 90)
    pole = degrees_float < 0 ? :S : :N
    whole, minutes, seconds = degree_fractions(degrees_float.abs)
    '%s%02d°%02d′%02d″' % [pole, whole, minutes, seconds]
  end

  def degree_fractions(degrees_float)
    degrees = degrees_float.floor
    minutes = (60 * (degrees_float - degrees)).floor
    seconds = 3600 * (degrees_float - degrees) - 60 * minutes
    [degrees, minutes, seconds]
  end
  
  def normalize_latlon(degrees_float, rollover_value)
    if degrees_float > rollover_value
      -rollover_value + (degrees_float.abs % rollover_value)
    elsif degrees_float < -rollover_value
      rollover_value - (degrees_float.abs % rollover_value)
    else
      degrees_float
    end
  end
end