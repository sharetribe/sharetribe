require 'test_helper'

class PeopleControllerTest < ActionController::TestCase

  def test_using_test_person
    @test_person = Person.test_person
    assert_not_nil( @test_person )
    assert_not_equal(0, @test_person.id)
    @test_person.coin_amount = 5
    assert_equal(5, @test_person.coin_amount)
    puts @test_person.id
    
  end

end
