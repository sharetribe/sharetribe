require 'test_helper'

class FavorTest < ActiveSupport::TestCase
  
  def test_payment_integer
    favor = favors(:valid_favor)
    
    favor.payment = 1.2
    assert !favor.valid?
    
    favor.payment = "plaa"
    assert !favor.valid?
  end
  
  def test_payment_above_zero
    favor = favors(:valid_favor)
    favor.payment = -1
    assert !favor.valid?
    
    #to be sure on the limit is ok
    favor.payment = 0
    assert favor.valid?
  end
  
  def test_valid_without_payment
    favor = favors(:valid_favor)
    favor.payment = nil
    assert favor.valid?
  end
  
  def test_title_length
    assert !favors(:too_long_title).valid?
    assert !favors(:too_short_title).valid?
    assert favors(:valid_title).valid?
  end
  
  def test_has_required_attributes
    assert !favors(:no_title).valid?
    assert !favors(:no_owner_id).valid?
  end
  
  def test_description_length
    assert !favors(:too_long_description).valid?
    assert favors(:valid_description).valid?
  end
    
  def test_blank_description
    favor = favors(:valid_favor)
    favor.description = " "
    assert favor.valid?
  end

  def test_nil_description
    favor = favors(:valid_favor)
    favor.description = nil
    assert favor.valid?
  end  
  
  def test_required_attributes_not_nil
    favor = Favor.new(:owner_id => nil, :title => nil)
    assert !favor.valid?
  end
  
end
