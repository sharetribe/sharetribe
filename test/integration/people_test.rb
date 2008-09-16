require 'test_helper'

class PeopleTest < ActionController::IntegrationTest
  fixtures :all

  def test_create_users
    # this is done twice to get two records in Kassi database
    # to detecet collisions primart keys
    #log_application_in  
    username = generate_random_username
    create_user({:person => {:username => username,
                 :password => "testi",
                 :email => "#{username}@example.com"}})
                 
    log_out
    #log_application_in  
    username = generate_random_username
    create_user({:person => {:username => username,
                 :password => "testi",
                 :email => "#{username}@example.com"}})
                 
    log_out
  end
  
  def test_only_open_session
    #used only to open session for debugging with console
    #log_application_in
  end
  
  private
  
  def create_user(params)
    post "people", params
    assert_response :success, @response.body
  end
end
