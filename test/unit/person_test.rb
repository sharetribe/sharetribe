require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  def test_person_attributes
    test_person = Person.test_person
    assert_equal("kassi_testperson1", test_person.name_or_username )
    assert_equal(0, test_person.coin_amount)
    test_person.coin_amount = 5
    assert_equal(5, test_person.coin_amount)
  end

end