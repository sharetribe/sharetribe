require 'test_helper'

class PeopleControllerTest < ActionController::TestCase

  def test_show_index
    get :index
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:people)
  end

  def test_using_test_person
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
    assert_not_nil( @test_person )
    assert_not_equal(0, @test_person.id)
    @session.destroy
  end

  def test_register_form
    get :new
    assert_response :success
    assert_template "new"
    assert_select 'form#new_person'
  end
  
  def test_render_profile_page
    submit_with_person :show, {
      :id => people(:one).id
    }, nil, nil, :get
    assert_response :success
    assert_template "show"
    assert_not_nil assigns(:person)
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:favor)
    assert_equal assigns(:items), [ items(:one) ]
    assert_equal assigns(:favors), [ favors(:one) ]
  end
  
  def test_create_users
    # this is done twice to get two records in Kassi database
    # to detect collisions in primary keys
    username = generate_random_username
    post "create", ({:person => {:username => username,
                 :password => "testi",
                 :email => "#{username}@example.com"}})
    assert_response :found, @response.body             
                 
    username = generate_random_username
    post "create", ({:person => {:username => username,
                 :password => "testi",
                 :email => "#{username}@example.com"}})
    assert_response :found, @response.body
  end
  
  def test_home
    get :home
    assert_response :found
    assert_redirected_to listings_path
    
    @test_person, @session = get_test_person_and_session
    get :home, {}, {:person_id => @test_person.id, :cookie => @session.cookie}
    #TODO should be different cases for allowed home view and unauthorized attempt, see people_controller#home
    assert_response :success
    assert_template "home"
    assert_equal 2, assigns(:listings).size
    assert_not_nil assigns(:person_conversations)
    assert_not_nil assigns(:comments)
    @session.destroy
  end
  
  
  private
  
  def generate_random_username(length = 12)
    chars = ("a".."z").to_a + ("0".."9").to_a
    random_username = "aaaTest"
    1.upto(length - 7) { |i| random_username << chars[rand(chars.size-1)] }
    return random_username
  end
  
end
