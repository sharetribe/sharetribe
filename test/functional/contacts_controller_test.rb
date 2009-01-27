require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  
  def test_show_index
    submit_with_person :index, { 
      :person_id => people(:one)
    }, nil, nil, :get
    assert_response :success
    assert_template 'index'  
    assert_not_nil assigns(:contacts)
  end
  
end
