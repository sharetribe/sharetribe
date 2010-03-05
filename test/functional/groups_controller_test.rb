require 'test_helper'

class GroupsControllerTest < ActionController::TestCase

  def setup
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
  end
  
  def teardown
    @session.destroy
  end
  
  def test_show_index
    get :index
    assert_response :success
    assert_template "index"
    assert_equal 10, assigns(:groups).size
  end
  
  def test_show_group
    get :show, { :id => groups(:one).id }, {:person_id => @test_person.id, :cookie => @cookie}
    assert_response :success, @response.body
    assert_template "show"
    assert_equal assigns(:group), groups(:one)
  end
  
  def test_show_new
    get :new, {}, {:person_id => @test_person.id, :cookie => @cookie}
    assert_response :success, @response.body
    assert_template "new"
    assert_not_nil assigns(:group)
  end
  
  def test_show_edit_form
    get :edit, { :id => groups(:one).id }, {:person_id => @test_person.id, :cookie => @cookie}
    assert_response :success, @response.body
    assert_template "edit"
    assert_not_nil assigns(:group)
  end
  
  def test_try_to_show_edit_form_for_group_when_not_admin
    get :edit, { :id => groups(:two).id }, {:person_id => @test_person.id, :cookie => @cookie}
    assert_redirected_to group_path(groups(:two))
  end
   
  def test_create_and_leave_group
    post :create, {
      :group => {
        :title => "Group for testing Kassi1234567", 
        :type => "open",
        :description => "This group is done in the automatic tests of Kassi and 
                         should be removed immediately afterwards."
      }
    },
    { :person_id => @test_person.id, :cookie => @session.cookie }
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
  
  def test_join_and_leave_group
    assert_equal 1, groups(:two).members(@cookie).size
    
    put :join, {:id => groups(:two).id, :person_id => @test_person.id}, {:person_id => @test_person.id, :cookie => @session.cookie}
    assert_equal [ :you_have_joined_to_group, groups(:two).title ], flash[:notice]
    assert_equal 2, groups(:two).members(@cookie).size
    
    put :leave, {:id => groups(:two).id, :person_id => @test_person.id}, {:person_id => @test_person.id, :cookie => @session.cookie}
    assert_equal [ :you_have_left_group, groups(:two).title, group_path(groups(:two)) ], flash[:notice]
    assert_equal 1, groups(:two).members(@cookie).size
  end
  
  def test_update_group
    put :update, {
      :group => {
        :title => "kassi_testgroup1",
        :description => "testiii"
      },
      :id => groups(:one).id
    }, 
    { :person_id => @test_person.id, :cookie => @session.cookie }
    assert_equal :group_info_updated, flash[:notice]
    assert_equal "kassi_testgroup1", groups(:one).title
    assert_equal "testiii", groups(:one).description
  end
  
  def test_try_to_create_invalid_group
    post :create, {
      :group => {
        :title => "G", 
        :type => "open",
        :description => ""
      }
    }, 
    { :person_id => @test_person.id, :cookie => @session.cookie }
    assert assigns(:group).errors.on(:title)
  end
  
  def test_try_to_do_invalid_update
    put :update, {
      :group => {
        :title => "", 
        :description => "sdfs"
      },
      :id => groups(:one).id
    }, 
    { :person_id => @test_person.id, :cookie => @session.cookie }
    assert assigns(:group).errors.on(:title)
  end
  
  def test_try_to_update_group_when_not_admin
    put :update, {
      :group => {
        :title => "sdf",
        :description => "sdfs"
      }, 
      :id => groups(:two).id
    }, 
    { :person_id => @test_person.id, :cookie => @session.cookie }
    assert_equal :you_must_be_admin_of_this_group_to_do_this, flash[:error]
    assert_redirected_to group_path(groups(:two))
  end
  
  def test_search_groups
    search("kassi_testgroup", 2)
    search("kassi_testgroup1", 1)
    search("", 0)
    search("kassi_testgroup3",0)
  end
  
  private
  
  def search(query, result_count)
    get :search, :q => query
    assert_response :success
    assert_equal result_count, assigns(:groups).size
  end
  
end
