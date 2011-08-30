require 'test_helper'
require 'rails/performance_test_help'
#require File.expand_path('../../helper_modules', __FILE__)

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionController::PerformanceTest
  
  def setup
    @author = Factory(:person)
    @community = Factory(:community, :domain => "test")
    
  end
  
  def create_listings(n=40)
    40.times do |n|
      Factory(:listing, :author => @author, 
      :listing_type => ( n%2 == 0 ? "request" : "offer" ),
      :share_types => [Factory(:share_type, :name => ( n%2 == 0 ? "buy" : "sell" ))],
      :communities => [@community])
    end
  end
  
  def test_homepage
    create_listings
    get 'http://test.lvh.me'
    assert_response :success   
  end
  
  def test_new_request_page
    get "http://test.lvh.me/en/listings/new/request"
    assert_response :success
  end
  
  # def test_homepage_no_cache
  #   get '/?nocache=1'
  # end
  
  # def test_listings_page
  #     get '/listings/categories/all_categories'
  #   end
  #   
  #   def test_people_page
  #     get '/people'
  #   end
  #   
  #   def test_random_listing_page
  #     get '/listings/random'
  #   end
  #   
  #   def test_items_page
  #     get '/items'
  #   end
  #   
  #   def test_favors_page
  #     get '/favors'
  #   end
  #   
  #   def test_groups_page
  #     get '/groups'
  #   end
  
  # def test_log_in_and_out
  #   post "/session", { :username => "kassi_testperson1", :password => "testi"}
  #   delete "/session"
  # end
  

  
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
