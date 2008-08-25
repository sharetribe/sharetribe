require 'test_helper'

class ListingCommentsControllerTest < ActionController::TestCase
  
  def test_accept_comment
    assert listings(:another_valid_listing).comments.empty?
    post :create, :listing_id => listings(:another_valid_listing)
    assert ! assigns(:listing).comments.empty?
  end
  
end
