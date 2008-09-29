require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  def setup
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
  end
  
  def teardown
    @session.destroy
  end

  def test_person_valid
    assert_not_nil(@test_person)
    assert_not_equal(0, @test_person.id, "Test_person.id is 0, possible reason is INT type for id in test DB.")
    assert(@test_person.valid?, "Test_person is not valid #{@test_person.errors.full_messages}")
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
  
  def test_add_to_kassi_db
    p = Person.add_to_kassi_db("testingID")
    assert_not_nil(p)
    assert_equal(Person, p.class)
    assert(Person.find_by_id("testingID"), "Person added to kassi DB was not found.")
    p.destroy
  end
end