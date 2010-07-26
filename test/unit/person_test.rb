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
  
  def test_username
     assert_equal("kassi_testperson1", @test_person.username(@cookie) )
  end
   
   
   def test_add_to_kassi_db
     p = Person.add_to_kassi_db("testingID")
     assert_not_nil(p)
     assert_equal(Person, p.class)
     assert(Person.find_by_id("testingID"), "Person added to kassi DB was not found.")
     p.destroy
   end
 
   # def test_street_address
   #   @test_person.set_street_address("SMT 49", @cookie)
   #   assert_equal("SMT 49", @test_person.street_address(@cookie))
   #   @test_person.update_attributes({'street_address' => "salainen"},@cookie)
   #   assert_equal("salainen", @test_person.street_address(@cookie))
   #   @test_person.set_street_address("Jämeräntaival 13 Y 85", @cookie)
   #   assert_equal("Jämeräntaival 13 Y 85", @test_person.street_address(@cookie), "Scandinavic letters Fail!")
   # end
   
   # def test_phone_number
   #   @test_person.set_phone_number("123456789-123", @cookie)
   #   assert_equal("123456789-123", @test_person.phone_number(@cookie))
   #   @test_person.set_phone_number("55555555", @cookie)
   #   assert_equal("55555555", @test_person.phone_number(@cookie))
   # end
   
end