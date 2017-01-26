class NavDB
  class UnknownPoint < StandardError; end
  def initialize(pts_enum)
    @idents = {}
    @per_class = {}
    pts_enum.each do |pt|
      raise "#{pt.inspect} has a nil identifier and will not be found in the database" if pt.ident.nil?
      @idents[pt.ident] ||= []
      @idents[pt.ident] << pt
      @per_class[pt.class] ||= []
      @per_class[pt.class] << pt
    end
  end
  
  def known?(identifier)
    !!@idents[identifier]
  end
  
  def of_class(point_class)
    @per_class.fetch(point_class)
  end
  
  def [](identifier)
    @idents[identifier] or raise UnknownPoint, "No waypoints matching %s found" % identifier
  end
end