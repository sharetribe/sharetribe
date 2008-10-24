require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
 
  def test_has_required_attributes
    assert_feedback_valid(:author_id, nil, false)
    assert_feedback_valid(:content, nil, false)
    assert_feedback_valid(:url, nil, false)
  end
 
  def test_author_association
    assert_equal people(:one), feedbacks(:one).author  
  end
 
  private
  
  def assert_feedback_valid(attribute, value, is_valid)
    feedback = feedbacks(:one)
    feedback.update_attribute(attribute, value)
    if is_valid
      assert feedback.valid?
    else
      assert !feedback.valid?
    end    
  end
  
end
