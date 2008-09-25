require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  def setup
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
  end

  def test_coin_amount
    assert_equal(0, @test_person.coin_amount)
    @test_person.coin_amount = 5
    assert_equal(5, @test_person.coin_amount)
  end
  
  def test_username
    assert_equal("kassi_testperson1", @test_person.username(@cookie) )
  end
  
  def test_name
    @test_person.set_given_name("Totti", @cookie)
    @test_person.set_family_name("Testaaja", @cookie)
    assert_equal("Totti Testaaja", @test_person.name(@cookie) )
  end
end