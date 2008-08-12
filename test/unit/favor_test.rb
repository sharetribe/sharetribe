require 'test_helper'

class FavorTest < ActiveSupport::TestCase
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
    blank_description = Favor.new(:owner_id => "pelle", :title => "title", :description => " ")
    assert blank_description.valid?
  end

  def test_nil_description
    nil_description = Favor.new(:owner_id => "matti", :title => "otsikko", :description => nil)
    assert nil_description.valid?
  end  
  
  def test_payment_length
    assert !favors(:too_long_payment).valid?
    assert favors(:valid_payment).valid? 
  end
  
  def test_nil_payment
    nil_payment = Favor.new(:owner_id => "ihan sama", :title => "nil-testi", :payment => nil)
    assert nil_payment.valid?
  end
    
  def test_blank_payment
    blank_payment = Favor.new(:owner_id => "taas mikä vaan", :title => "blank-testi", :payment => " ")
    assert blank_payment.valid?
  end
  
  def test_required_attributes_not_nil
    favor = Favor.new(:owner_id => nil, :title => nil)
    assert !favor.valid?
  end
  
end
