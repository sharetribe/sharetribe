require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def test_has_required_attributes
    assert messages(:valid_message).valid?
    assert_message_valid(:sender_id, nil, false)
    assert_message_valid(:content, nil, false)
  end

  def test_conversation_id_int
    assert_message_valid(:conversation_id, "testi", false)
    assert_message_valid(:conversation_id, 1.2, false)
  end

  def test_sender_association
    assert_equal people(:one), messages(:valid_message).sender   
  end

  def test_conversation_association
    assert_equal conversations(:one), messages(:valid_message).conversation    
  end

  private
  
  def assert_message_valid(attribute, value, is_valid)
    message = messages(:valid_message)
    message.update_attribute(attribute, value)
    if is_valid
      assert message.valid?
    else
      assert !message.valid?
    end    
  end

end
