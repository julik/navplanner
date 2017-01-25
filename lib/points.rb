module PointInfo
  def navigable?
    false
  end
  
  def magnetic_variation
    magvar_rads = Magvar.magvar(Haversine.rpd(lat), Haversine.rpd(lon), Time.utc(2020,1,1),1000)
    Haversine.dpr(magvar_rads)
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
  def navigable?; true; end
end

class VOR   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :reception_range_nm)
  include PointInfo
  def navigable?; true; end
end

class DME   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :nm_dme_bias)
  include PointInfo
  def navigable?; true; end
end

class RSBN   < Struct.new(:lat, :lon, :ident, :name, :chan, :elev_mtr)
  include PointInfo
  def navigable?; true; end
end

