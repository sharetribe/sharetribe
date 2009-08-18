require 'test_helper'

class GroupsControllerTest < ActionController::TestCase

  def setup
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
  end
  
  def teardown
    @session.destroy
  end
  
  def test_create_and_leave_group
    post :create, {:group => {:title => "Group for testing Kassi11", :type => "open" #,
         #:description => "This group is done in the automatic tests of Kassi and 
        #                  should be removed immediately afterwards."
                          }},
         {:person_id => @test_person.id, :cookie => @session.cookie}
    #puts @response.body 
    assert_response :found, "\n Redirect did not happen as expected after group creation. Probably creation failed for some reason. Could be that the name was already taken."
    assert_not_nil assigns(:group)
    id = assigns(:group).id

    #check that it exists
    get :show, {:id => id}, {:person_id => @test_person.id, :cookie => @session.cookie}
    assert_response :success, @response.body
    
    
    # leave group and check that is deleted (as the last person leaves)
    delete :leave, {:id => id, :person_id => @test_person.id}, {:person_id => @test_person.id, :cookie => @session.cookie}
    assert_response :found, @response.body
    get :show, {:id => id}, {:person_id => @test_person.id, :cookie => @session.cookie}
    assert_response :found, @response.body
    assert_redirected_to groups_path
  end
end
