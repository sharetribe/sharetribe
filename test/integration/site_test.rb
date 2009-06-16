require 'test_helper'

# Test that the site works in general, the front page is loaded etc.
class SiteTest < ActionController::IntegrationTest
  def test_listingspage
    get "/listings"
    assert_response :success, @response.body
    assert_select 'title', /Kassi/
  end

  
end