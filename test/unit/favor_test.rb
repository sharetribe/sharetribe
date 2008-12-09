require 'test_helper'

class FavorTest < ActiveSupport::TestCase
  
  def test_has_required_attributes
    favor = Favor.new(:title => "saha", :owner_id => "dMF4WsJ7Kr3BN6ab9B7ckF")
    assert favor.valid?
    favor = Favor.new(:title => nil, :owner_id => "dMF4WsJ7Kr3BN6ab9B7ckF")
    assert !favor.valid?
    favor = Favor.new(:title => "saha", :owner_id => nil)
    assert !favor.valid?
  end  

  def test_title_length
    assert_favor_valid(:title, "aivan_järjettömän_liian_pitkä_nimi_ollakseen_tässä_yhteydessä_validi_palvelus", false)
    assert_favor_valid(:title, "p", false)
  end
  
  def test_owner_association
    assert_equal favors(:one).owner, people(:one)  
  end
  
  private
  
  def assert_favor_valid(attribute, value, is_valid)
    favor = Favor.new(:title => "title", :owner_id => "dMF4WsJ7Kr3BN6ab9B7ckF")
    favor.update_attribute(attribute, value)
    if is_valid
      assert favor.valid?
    else
      assert !favor.valid?
    end
  end
  
end
