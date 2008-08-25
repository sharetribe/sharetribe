require 'test_helper'

class FilterTest < ActiveSupport::TestCase
  def test_keywords_is_serialized
    filter = Filter.new(:person_id => "Emmi", :keywords => ["hauskaa", "koodata", "kassia"])

    filter.save
    
    assert filter.valid?
    
    retrieved = Filter.find(:last)
    assert_equal "hauskaa", retrieved.keywords[0]
    assert_equal "koodata", retrieved.keywords[1]
    assert_equal "kassia", retrieved.keywords[2]
    assert_equal nil, retrieved.keywords[3]
  end
  
  def test_has_required_attributes
    filter = filters(:valid_filter)
    assert filter.valid?
    
    filter.person_id = nil
    assert !filter.valid?
    
    filter = filters(:valid_filter)
    filter.keywords = nil
    assert !filter.valid?
  end
end
