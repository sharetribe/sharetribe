require 'test_helper'

class ListingCommentsControllerTest < ActionController::TestCase
  
  def test_accept_comment
    listing = listings(:another_valid_listing)
    assert listing.comments.empty?
    post :create, :listing_id => listing.id, :listing_comment => {
      :content => "Testikommentti"
    }  
    #assert ! assigns(:listing).comments.empty?
  end
  
end
