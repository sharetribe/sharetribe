require 'test_helper'

class PersonConversationTest < ActiveSupport::TestCase
  
  def test_has_required_attributes
    tested = person_conversations(:one)
    assert tested.valid?
     
    tested.person_id = nil
    assert !tested.valid?
     
    tested = person_conversations(:one)
    tested.conversation_id = nil
    assert !tested.valid?
  end
  
end
