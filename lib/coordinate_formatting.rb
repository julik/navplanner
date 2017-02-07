module CoordinateFormatting
  extend self
  def decimal_degrees(degrees)
    "%03.1f°" % [degrees]
  end
  
  def degrees_with_minutes(degrees_float)
    degrees = degrees_float.floor
    minutes = (60 * (degrees_float - degrees)).round
    
    '%03d°%02d′' % [degrees, minutes]
  end
  
  def longitude(degrees_float)
    pole = degrees_float < 0 ? :W : :E
    whole, minutes, seconds = degree_fractions(degrees_float.abs)
    '%s%03d°%02d′%02d″' % [pole, whole, minutes, seconds]
  end
  
  def latitude(degrees_float)
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
end