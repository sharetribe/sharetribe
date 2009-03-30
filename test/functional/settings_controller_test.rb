require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @cookie = @session1.cookie
  end
  
  def teardown
    @session1.destroy
    @session2.destroy
  end
  
  def test_show_settings
    submit_with_person :show, {
      :person_id => people(:one).id
    }, nil, nil, :get
    assert_response :success
    assert_template "show"
    assert_not_nil assigns(:person)
  end
  
  def test_change_email_success
    change_email("uusi.maili@maili.com", :email_updated_successfully, true)
  end
  
  def test_change_email_invalid
    change_email("uusi_maili", :email_is_invalid, false)
  end
  
  def test_change_email_taken
    change_email("kassi_testperson2@example.com", :email_has_already_been_taken, false)
  end  
  
  def test_change_password_success
    change_password("testi", "testi", :password_updated_successfully, true)
  end
  
  def test_change_password_dont_match
    change_password("testi", "testi2", :passwords_dont_match, false)
  end

  def test_change_password_too_long
    change_password("testitestitestitestitestitestitestitestitestitesti", "testitestitestitestitestitestitestitestitestitesti", :password_is_invalid, false)
  end
  
  def test_update
    submit_with_person :update, { 
      :settings => { 
        :email_when_new_message => 0,
        :email_when_new_comment => 0 
      },
      :person_id => @test_person1.id
    }, :person, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], :settings_updated_successfully
  end
  
  private 
  
  def change_email(email, message, should_succeed)
    submit_with_person :change_email, { 
      :person => { :email => email },
      :person_id => @test_person1.id
    }, :person, nil, :put
    assert_response :found, @response.body
    if should_succeed
      assert_equal email, @test_person1.email(@cookie)
      assert_equal flash[:notice], message
    else  
      assert_equal flash[:error], message
    end
  end
  
  def change_password(password1, password2, message, should_succeed)
    submit_with_person :change_password, { 
      :person => { :password => password1, :password2 => password2 },
      :person_id => @test_person1.id
    }, :person, nil, :put
    assert_response :found, @response.body
    if should_succeed
      assert_equal flash[:notice], message
    else  
      assert_equal flash[:error], message
    end
  end
  
end
