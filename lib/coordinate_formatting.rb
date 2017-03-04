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
    degrees_float = normalize_lon(degrees_float)
    pole = degrees_float < 0 ? :W : :E
    whole, minutes, seconds = degree_fractions(degrees_float.abs)
    '%s%03d°%02d′%02d″' % [pole, whole, minutes, seconds]
  end
  
  def latitude(degrees_float)
    degrees_float = normalize_lat(degrees_float)
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

  private

  def normalize_lon(input_degrees)
    degrees_float = input_degrees % 360
    sign = degrees_float < 1 ? -1 : 1
    if degrees_float.abs > 180
      (degrees_float - 360) * sign
    else
      degrees_float
    end
  end

  def normalize_lat(input_degrees)
    degrees_float = input_degrees % 360
    # Sine is always relative to the equator (horizontal diam of the unit circle)
    sin_phi = Math.sin(degrees_float * Math::PI / 180)
    Math.asin(sin_phi) / Math::PI * 180
  end
end