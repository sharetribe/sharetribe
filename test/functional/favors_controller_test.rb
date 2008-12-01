require 'test_helper'

class FavorsControllerTest < ActionController::TestCase

  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
    @cookie = @session1.cookie
  end

  def test_show_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:letters)
    assert_not_nil assigns(:favor_titles)
  end
  
  def test_show_favor
    get :show, :id => "hieronta"
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:title)
    assert_equal assigns(:favors), [ favors(:one) ]
  end
  
  def test_create_and_delete_favor
    submit_with_person :create, { 
      :favor => { :title => "TestTitle" }
    }, :favor, :owner_id
    assert_response :found, @response.body
    assert_not_nil flash[:notice]
    assert ! assigns(:favor).new_record?
    submit_with_person :destroy, {
      :id => assigns(:favor).id 
    }, :favor, :owner_id, :delete
    assert_redirected_to @test_person1
  end

  def test_edit_favor
    submit_with_person :update, { 
      :favor => { :title => "muutettu_vasara" },
      :id => favors(:one).id,
      :person_id => @test_person1.id
    }, :favor, :owner_id, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], :favor_updated
  end

end
