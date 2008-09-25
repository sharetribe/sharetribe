require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def test_has_required_attributes
    message = messages(:valid_message)
    
    #valid with required attributes
    assert message.valid?
    
    #invalid without sender id
    message.sender_id = nil
    assert !message.valid?
    
  end

end
