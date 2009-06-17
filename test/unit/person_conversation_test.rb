require 'test_helper'

class PersonConversationTest < ActiveSupport::TestCase
  
  def test_has_required_attributes
    tested = person_conversations(:one)
    assert tested.valid?
  end
  
end
