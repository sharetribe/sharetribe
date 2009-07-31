require 'test_helper'

class PersonCommentTest < ActiveSupport::TestCase

  def test_has_required_attributes
    comment = person_comments(:valid_person_comment)

    #valid with required attributes
    assert comment.valid?

    #invalid without author_id
    comment.author_id = nil
    assert !comment.valid?

    #invalid without target_person_id
    comment = person_comments(:valid_person_comment)
    comment.target_person_id = nil
    assert !comment.valid?

    #invalid without grade
    comment = person_comments(:valid_person_comment)
    comment.grade = nil
    assert !comment.valid?

  end

  def test_grade
    comment = person_comments(:valid_person_comment)
    
    #valid with 1..5
    comment.grade = 0
    until comment.grade == 1.2
      assert comment.valid?
      comment.grade += 0.2
    end
    
    #invalid with greater or lower values
    assert !comment.valid?
    
    comment.grade = -1
    assert !comment.valid? 
    
    #invalid with string values
    comment.grade = "test"
    assert !comment.valid?
  end

end
