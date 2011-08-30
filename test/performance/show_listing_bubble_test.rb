require 'test_helper'
require 'rails/performance_test_help'
#require File.expand_path('../../helper_modules', __FILE__)

# Profiling results for each test method are written to tmp/performance.
class ShowListingBubbleTest < ActionController::PerformanceTest
  
  def setup
    author = Factory(:person)
    @listing = Factory(:listing, :author => Person.first)
  end
  
  def test_show_listing_bubble
    get "http://test.lvh.me/en/listings_bubble/#{@listing.id.to_s}"
    assert_response :success
  end
  
end