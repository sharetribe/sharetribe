require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @cookie = @session1.cookie
  end
  
  def teardown
    @session1.destroy
    @session2.destroy
  end

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
  
  def test_update
    submit_with_person :update, { 
      :person => { 
        :given_name => "Teppo",
        :family_name => "Testaaja",
        :address => "Osoite",
        :phone_number => "0700-715517" 
      },
      :id => @test_person1.id
    }, :person, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], :person_updated_successfully
    assert_equal @test_person1.given_name, "Teppo"
    assert_equal @test_person1.family_name, "Testaaja"
    assert_equal @test_person1.address, "Osoite"
    assert_equal @test_person1.phone_number, "0700-715517"
  end
  
  def test_invalid_given_name
    update_with_invalid_data(:given_name, "TeppoTeppoTeppoTeppoTeppoTeppoTeppo", :given_name_is_too_long)
  end
  
  def test_invalid_family_name
    update_with_invalid_data(:family_name, "TeppoTeppoTeppoTeppoTeppoTeppoTeppo", :family_name_is_too_long)
  end
  
  def test_invalid_address  
    update_with_invalid_data(:unstructured_address, "TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppo
    TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppo
    TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppo
    TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppo
    TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppo
    TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppo
    TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppo
    TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppo    
    ", :address_is_too_long)
  end
  
  def test_invalid_phone_number  
    update_with_invalid_data(:phone_number, "TeppoTeppoTeppoTeppoTeppoTeppoTeppo", :phone_number_is_too_long)
  end
  
  def test_search_people_view
    get :search
    assert_response :success
    assert_template 'search'
  end
  
  def test_search_people
    search("dsfds", 0)
    search("*", 1)
    #puts assigns(:people).inspect
    #search("Teppo", 1)
    #search("*epp*", 1)
  end
  
  private
  
  def generate_random_username(length = 12)
    chars = ("a".."z").to_a + ("0".."9").to_a
    random_username = "aaaTest"
    1.upto(length - 7) { |i| random_username << chars[rand(chars.size-1)] }
    return random_username
  end
  
  def search(query, result_count)
    get :search, :q => query
    assert_response :success
    assert_equal result_count, assigns(:people).size
    assert_template 'search'
  end
  
  def update_with_invalid_data(key, value, error)
    submit_with_person :update, { 
      :person => { 
        key => value
      },
      :id => @test_person1.id
    }, :person, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:error], error
  end
  
end
