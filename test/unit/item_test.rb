require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  def test_has_required_attributes
    item = Item.new(:title => "saha", :owner_id => "dMF4WsJ7Kr3BN6ab9B7ckF")
    assert item.valid?
    item = Item.new(:title => nil, :owner_id => "dMF4WsJ7Kr3BN6ab9B7ckF")
    assert !item.valid?
    item = Item.new(:title => "saha", :owner_id => nil)
    assert !item.valid?
  end  

  def test_title_length
    assert_item_valid(:title, "aivan_järjettömän_liian_pitkä_nimi_ollakseen_tavaraaaaaaaaaaaaaaaaaaaaa", false)
    assert_item_valid(:title, "p", false)
  end
  
  def test_title_already_exists
    assert_item_valid(:title, "vasara", false)
  end
  
  def test_owner_association
    assert_equal items(:one).owner, people(:one)  
  end
  
  private
  
  def assert_item_valid(attribute, value, is_valid)
    item = Item.new(:title => "title", :owner_id => "dMF4WsJ7Kr3BN6ab9B7ckF")
    item.update_attribute(attribute, value)
    if is_valid
      assert item.valid?
    else
      assert !item.valid?
    end
  end

end
