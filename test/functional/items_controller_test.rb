require 'test_helper'

class ItemsControllerTest < ActionController::TestCase

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
    assert_not_nil assigns(:item_titles)
  end

  def test_show_item
    get :show, :id => "vasara"
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:title)
    assert_equal assigns(:items), [ items(:one) ]
  end

  def test_create_and_delete_item
    submit_with_person :create, { 
      :item => { :title => "TestTitle" }
    }, :item, :owner_id
    assert_response :found, @response.body
    assert_not_nil flash[:notice]
    assert ! assigns(:item).new_record?
    submit_with_person :destroy, {
      :id => assigns(:item).id 
    }, :item, :owner_id, :delete
    assert_redirected_to @test_person1
  end

  def test_create_item_with_title_that_already_exists 
    submit_with_person :create, { 
      :item => { :title => "vasara" }
    }, :item, :owner_id
    assert assigns(:item).errors.on(:title)
  end

  def test_edit_item
    submit_with_person :update, { 
      :item => { :title => "muutettu_vasara" },
      :id => items(:one).id,
      :person_id => @test_person1.id
    }, :item, :owner_id, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], :item_updated
  end

end
