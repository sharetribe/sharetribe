require 'test_helper'

class ConversationTest < ActiveSupport::TestCase

  def test_listing_id_int
    conversation = conversations(:one)
    
    conversation.listing_id = "testi"
    assert !conversation.valid?
    
    conversation.listing_id = "1.2"
    assert !conversation.valid?
    
    conversation.listing_id = nil
    assert conversation.valid?
  end
  
  
end
