require 'test_helper'

class PeopleControllerTest < ActionController::TestCase

  def test_using_test_person
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
    assert_not_nil( @test_person )
    assert_not_equal(0, @test_person.id)
    @test_person.coin_amount = 5
    assert_equal(5, @test_person.coin_amount)
  end
  
  def test_register_form
    get :new
    assert_response :success
    assert_template "new"
    assert_select 'form#new_person'
  end
  
  # def test_render_profile_page
  #   get :show
  #   assert_response :success
  #   assert_template "show"
  # end

end
