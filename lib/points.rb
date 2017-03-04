require 'magvar'

module PointInfo
  def elev_km
    10.0 # 10000 mtr above MSL is ~ standard cruise altitude for a Tu-154
  end
  
  def radio?
    false
  end
  
  def magnetic_variation
    Magvar.variation_at(lat, lon, elev_km, magvar_on_day = Time.utc(2020,1,1))
  end
end

class Point < Struct.new(:lat, :lon, :ident, :name)
  include PointInfo
end

class FIX   < Point
  include PointInfo
end

class APT   < Point
  include PointInfo
end

class NDB   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :reception_range_nm)
  include PointInfo
  def elev_km
    ft_to_km = 0.0003048
    elev_ft * ft_to_km
  end
  
  def radio?
    true
  end

  def to_s
    "NDB %s (%s %s)\n%s" % [freq_int, ident, Morse.code(ident), name]
  end
end

class VOR   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :reception_range_nm)
  include PointInfo

  def elev_km
    ft_to_km = 0.0003048
    elev_ft * ft_to_km
  end
  
  def radio?
    true
  end

  def to_s
    "VOR %s (%s %s)\n%s" % [freq_int, ident, Morse.code(ident), name]
  end
end

class DME < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :nm_dme_bias)
  include PointInfo

  def elev_km
    ft_to_km = 0.0003048
    elev_ft * ft_to_km
  end
  
  def radio?
    true
  end

  def to_s
    "DME %s (%s %s)\n%s" % [freq_int, ident, Morse.code(ident), name]
  end
end

class RSBN   < Struct.new(:lat, :lon, :ident, :name, :chan, :elev_mtr)
  include PointInfo

  def elev_km
    elev_mtr / 1000.0
  end
  
  def radio?
    true
  end
  
  def to_s
    "%s (%s %s)\n%s" % [chan, ident, Morse.code(ident), name]
  end
end

