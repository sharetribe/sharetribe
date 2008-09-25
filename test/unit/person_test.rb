require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  def test_coin_amount
    test_person = Person.test_person
    assert_equal(0, test_person.coin_amount)
    test_person.coin_amount = 5
    assert_equal(5, test_person.coin_amount)
  end
  
  def test_username
    test_person = Person.test_person
    assert_equal("kassi_testperson1", test_person.username )
  end
  
  def test_name
    test_person = Person.test_person
    test_person.given_name = "Totti"
    test_person.family_name = "Testaaja"
    assert_equal("Totti Testaaja", test_person.name )
  end

end