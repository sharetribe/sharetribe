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
    comment.grade = 1
    until comment.grade == 6
      assert comment.valid?
      comment.grade += 1
    end
    
    #invalid with greater or lower values
    assert !comment.valid?
    
    comment.grade = 0
    assert !comment.valid? 
    
    #invalid with not integer values
    comment.grade = "test"
    assert !comment.valid?
    
    comment.grade = 1.2
    assert !comment.valid?
  end
  
  def test_task_type
    comment = person_comments(:valid_person_comment)
    PersonComment::VALID_TASK_TYPES.each do |valid_task_type|
      comment.task_type = valid_task_type
      assert comment.valid?
    end
    
    comment.task_type = "testi"
    assert !comment.valid?
  end
  
  def test_task_id_int
    comment = person_comments(:valid_person_comment)
    
    comment.task_id = "testi"
    assert !comment.valid?
    
    comment.task_id = 1.2
    assert !comment.valid?
  end
end
