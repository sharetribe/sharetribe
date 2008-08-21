require 'test_helper'

class ReadListingTest < ActiveSupport::TestCase
  
  def test_has_required_attributes
    tested = read_listings(:one)
    assert tested.valid?
     
    tested.person_id = nil
    assert !tested.valid?
     
    tested = read_listings(:one)
    tested.listing_id = nil
    assert !tested.valid?
  end

end
