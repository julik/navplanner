class Navlister
  class NavdataState < Struct.new(:airway_files, :navaid_files, :airport_files, :fix_files); end
  class NavDataFile < Struct.new(:path, :size); end
  
  def initialize(xp_dir_path)
    @xp_dir_path = File.expand_path(xp_dir_path)
  end
  
  def detect
    # Always sort 
    nav_files = list_with_class('**/earth_nav.dat')
    awy_files = list_with_class('**/earth_awy.dat')
    apt_files = list_with_class('**/apt.dat')
    fix_files = list_with_class('**/earth_fix.dat')
    NavdataState.new(awy_files, nav_files, apt_files, fix_files)
  end
  
  private

  def list_with_class(glob)
    apt_paths = Dir.glob(File.join(@xp_dir_path, glob))
    apt_paths.map{|full_path|
      NavDataFile.new(full_path, File.size(full_path))
    }.sort_by(&:size).reverse
  end
end

if __FILE__ == $0
  f = '/Volumes/FASZT/XPLANE10/X-Plane 10'

  lister = Navlister.new(f)
  lists = lister.detect
  lists.apt_files.each do |a|
    puts a.inspect
  end
end
