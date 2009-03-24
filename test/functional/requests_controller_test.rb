require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  
  # Accepting and rejecting friend requests is tested in integration tests
  def test_show_friends
    submit_with_person :index, { :person_id => people(:one) }, nil, nil, :get
    assert_response :success
    assert_template 'index'
    assert_equal 0, assigns(:requesters).size
  end

end
