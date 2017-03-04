require 'sinatra/base'
require 'haml'
require 'thread'

class NavplannerWeb < Sinatra::Base
  set :views, File.join(__dir__, "web_app_views")
  IncorrectPlan = Class.new(StandardError)
  
  before do
    lang_code = params[:lang] || :en
    I18n.locale = lang_code
  end

  get '/' do
    haml :index
  end
  
  post '/' do
    wpt_list = params[:waypoints].to_s
    wpt_list = wpt_list.strip.split(/\s+/).map(&:upcase)
    @parsed_wpt_list = wpt_list.join(' ')
    
    begin
      raise IncorrectPlan, "Need at least 2 waypoints" if wpt_list.length < 2
      db = load_nav_database

      # Parse legs from the waypoint list. In practice this is the only
      # phase that can lead to an error.
      legs = Planner.wyaypoint_list_to_legs(db, wpt_list)
    
      # Print a normal great-circle plan
      @result_fpl = buffer{|b| PlanPrinter.print_plan(legs, b) }
    
      # Print a palette report for NVU use
      beacon_list = db.of_class(RSBN)
      @result_nvu = buffer{|b| NVUPrinter.new.print_plan(legs, beacon_list, b) }

      # Print a plan for NAS-1
      @result_nas = buffer{|b| NAS1Printer.new.print_plan(legs, b) }

      # Print a plan that can be loaded into the KLN
      @result_kln = buffer{|b| XPFMSPrinter.print_plan(legs, b) }
    rescue => planning_error
      @error = planning_error
    end
    
    haml :index
  end

  DB_CACHE_MUX = Mutex.new

  def load_nav_database
    DB_CACHE_MUX.synchronize do
      @@cached_db ||= begin
        xp_path = ENV.fetch('X_PLANE_INSTALL_PATH') { File.join(__dir__, '/../spec/test_xp_data_20170129') }
        parser = ParserLoader.new(xp_path)
        NavDB.new(parser.load_cache)
      end
    end
  end

  def t(*a)
    I18n.translate(*a, scope: :web)
  end

  def buffer
    out = StringIO.new
    yield(out)
    out.string
  end
end
