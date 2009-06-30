require 'test_helper'
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest
  def test_homepage
    get '/'
  end
  
  def test_people_page
    get '/people'
  end
  
  def test_random_listing_page
    get '/listings/random'
  end
  
  def test_items_page
    get '/items'
  end
  
  def test_favors_page
    get '/favors'
  end
  
  def test_groups_page
    get '/groups'
  end
  
  #TODO following tests
  #view own profile
  #registration
  #change own address
  
end
