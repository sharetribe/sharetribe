require 'test_helper'

# Test that the site works in general, the front page is loaded etc.
class SiteTest < ActionController::IntegrationTest
  def test_listingspage
    get "/listings"
    assert_response :success, "Failed loading listings page"
    assert_select 'title', /Kassi/
  end
  
  def test_groups_page
    get '/groups'
    assert_response :success, "Failed loading groups page"
    assert_select 'title', /Kassi/
  end

  
end