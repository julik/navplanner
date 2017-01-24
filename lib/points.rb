class Point < Struct.new(:lat, :lon, :ident, :name); end
class FIX   < Point; end
class APT   < Point; end
class NDB   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :reception_range_nm); end
class VOR   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :reception_range_nm); end
class DME   < Struct.new(:lat, :lon, :ident, :name, :elev_ft, :freq_int, :nm_dme_bias); end


