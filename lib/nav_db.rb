class NavDB
  class UnknownPoint < StandardError; end
  def initialize(pts_enum)
    @idents = {}
    pts_enum.each do |pt|
      raise "#{pt.inspect} has a nil identifier and will not be found in the database" if pt.ident.nil?
      @idents[pt.ident] ||= []
      @idents[pt.ident] << pt
    end
  end
  
  def known?(identifier)
    !!@idents[identifier]
  end
  
  def [](identifier)
    @idents[identifier] or raise UnknownPoint, "No waypoints matching %s found" % identifier
  end
end