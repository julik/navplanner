module PointInfo
  def radio?
    false
  end
  
  def magnetic_variation
    var_r = Magvar.variation_at(Haversine.rpd(lat), Haversine.rpd(lon), 0)
    Haversine.dpr(var_r)
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
  def radio?; true; end
  def to_s
    "NDB %s (%s %s)\n%s" % [freq_int, ident, Morse.code(ident), name]
  end
end

class VOR   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :reception_range_nm)
  include PointInfo
  def radio?; true; end
  def to_s
    "VOR %s (%s %s)\n%s" % [freq_int, ident, Morse.code(ident), name]
  end
end

class DME   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :nm_dme_bias)
  include PointInfo
  def radio?; true; end
  def to_s
    "DME %s (%s %s)\n%s" % [freq_int, ident, Morse.code(ident), name]
  end
end

class RSBN   < Struct.new(:lat, :lon, :ident, :name, :chan, :elev_mtr)
  include PointInfo
  def radio?; true; end
  def to_s
    "%s (%s %s)\n%s" % [chan, ident, Morse.code(ident), name]
  end
end

