require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  def test_title_length
    assert !items(:too_short_title).valid?
    assert !items(:too_long_title).valid?
    assert items(:valid_title).valid?
  end
  
  def test_has_required_attributes
    assert !items(:no_title).valid?
    assert !items(:no_owner_id).valid?
  end
  
  def test_attributes_not_nil
    item = Item.new
    assert !item.valid?
  end

end
