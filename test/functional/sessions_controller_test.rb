require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def test_login_and_logout
    post :create, { :username => "testi", :password => "testi"}
    assert_response :found
    assert_not_nil session[:cookie]

    delete :destroy
    assert_response :found
    assert_nil session[:cookie]
  end
end
