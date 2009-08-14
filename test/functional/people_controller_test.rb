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
    get :new, {}, { :consent_accepted => "true" }
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
    #assert_equal assigns(:items), [ items(:one) ]
    assert(assigns(:items).include?(items(:one)), "The owned item is not shown.")
    assert_equal assigns(:favors), [ favors(:one) ]
  end
  
  def test_create_users
    # this is done twice to get two records in Kassi database
    # to detect collisions in primary keys
    
    username = generate_random_username
    post "create", { :person => { :username => username,
                 :password => "testi",
                 :password2 => "testi",
                 :given_name => "testi",
                 :family_name => "hemmo",
                 :email => "#{username}@example.com"}},
                  { :consent_accepted => "true" }
    assert_redirected_to home_person_path(assigns(:person))          
                 
    username = generate_random_username
    post "create", {:person => {:username => username,
                 :password => "testi",
                 :password2 => "testi",
                 :given_name => "testi",
                 :family_name => "hemmo",
                 :email => "#{username}@example.com"}},
                 { :consent_accepted => "true" }
    assert_redirected_to home_person_path(assigns(:person))
  end
  
  def test_home
    get :home
    assert_response :success
    assert_equal 8, assigns(:content_items).size
    assert_equal 0, assigns(:kassi_events).size
    
    @test_person, @session = get_test_person_and_session
    get :home, {}, {:person_id => @test_person.id, :cookie => @session.cookie}
    #TODO should be different cases for allowed home view and unauthorized attempt, see people_controller#home
    assert_response :success
    assert_template "home"
    assert_equal 9, assigns(:content_items).size
    assert_equal 0, assigns(:kassi_events).size
    @session.destroy
  end
  
  def test_update
    submit_with_person :update, { 
      :person => { 
        :given_name => "Teppo",
        :family_name => "Testaaja",
        :street_address => "Osoite",
        :postal_code => "00000",
        :locality => "Postitoimipaikka",
        :phone_number => "0700-715517" 
      },
      :id => @test_person1.id
    }, :person, nil, :put
    assert_response :success, @response.body
    assert_equal flash[:notice], :person_updated_successfully
    assert_equal "Testaaja", @test_person1.family_name(@cookie) 
    assert_equal "Teppo", @test_person1.given_name(@cookie)
    assert_equal "Osoite", @test_person1.street_address(@cookie)
    assert_equal @test_person1.postal_code(@cookie), "00000"
    assert_equal @test_person1.locality(@cookie), "Postitoimipaikka"
    assert_equal @test_person1.phone_number(@cookie), "0700-715517"
  end
  
  def test_invalid_given_name
    update_with_invalid_data(:given_name, "TeppoTeppoTeppoTeppoTeppoTeppoTeppo", :given_name_is_too_long)
  end
  
  def test_invalid_family_name
    update_with_invalid_data(:family_name, "TeppoTeppoTeppoTeppoTeppoTeppoTeppo", :family_name_is_too_long)
  end
  
  def test_invalid_street_address  
    update_with_invalid_data(:street_address, "TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoT", :street_address_is_too_long)
  end
  
  def test_invalid_postal_code  
    update_with_invalid_data(:postal_code, "TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoT", :postal_code_is_too_long)
  end
  
  def test_invalid_locality  
    update_with_invalid_data(:locality, "TeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoTeppoT", :locality_is_too_long)
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
    search("Teppo", 1)
    search("epp", 1)
  end
  
  private
  
  def generate_random_username(length = 12)
    chars = ("a".."z").to_a + ("0".."9").to_a
    random_username = "aaaTest"
    1.upto(length - 7) { |i| random_username << chars[rand(chars.size-1)] }
    return random_username
  end
  
  def search(query, result_count)
    submit_with_person :search, {
      :q => query
    }, nil, nil, :get
    assert_response :success
    assert_equal result_count, assigns(:people).size, "unexpected search result with #{query}"
    assert_template 'search'
  end
  
  def update_with_invalid_data(key, value, error)
    submit_with_person :update, { 
      :person => { 
        key => value
      },
      :id => @test_person1.id
    }, :person, nil, :put
    assert_response :success, @response.body
    assert_equal flash[:error], error
  end
  
end
