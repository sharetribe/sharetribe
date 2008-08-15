require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def test_has_required_attributes
    message = messages(:valid_message)
    
    #valid with required attributes
    assert message.valid?
    
    #invalid without sender id
    message.sender_id = nil
    assert !message.valid?
    
    #invalid wihtout receiver
    message.receiver_id = nil
    assert !message.valid?
    
  end

  def test_listing_id_int
    message = messages(:valid_message)
    
    message.listing_id = "testi"
    assert !message.valid?
    
    message.listing_id = "1.2"
    assert !message.valid?
    
    message.listing_id = nil
    assert message.valid?
  end
  
end
