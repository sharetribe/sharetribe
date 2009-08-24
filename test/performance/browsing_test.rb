require 'test_helper'
require 'performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest
  def test_homepage
    get '/'
  end
  
  def test_listings_page
    get '/listings/categories/all_categories'
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
  
  def test_log_in_and_out
    post "/session", { :username => "kassi_testperson1", :password => "testi"}
    delete "/session"
  end
  
  # def test_login_and_create_group_and_leave_it
  #   post "/session", { :username => "kassi_testperson1", :password => "testi"}
  #   post "/groups", {:group_title => "test_group44", :group_description => "A group just for a quick test."}
  #   
  #   # test not finished, should pick the group id, not trivial...
  #   #http://localhost:3000/people/bU8aHSBEKr3AhYaaWPEYjL/groups/cToI7CzxWr3PaKaaWPEYjL/leave
  #   
  #   delete "/session"
  # end
  
  #TODO following tests
  #view own profile
  #registration
  #change own address
  
end
