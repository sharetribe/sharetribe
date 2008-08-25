require 'test_helper'

class InterestingListingTest < ActiveSupport::TestCase
  def test_has_required_attributes
    tested = interesting_listings(:one)
    assert tested.valid?
     
    tested.person_id = nil
    assert !tested.valid?
     
    tested = interesting_listings(:one)
    tested.listing_id = nil
    assert !tested.valid?
  end
end
