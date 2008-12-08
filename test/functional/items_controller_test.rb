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
  
  def test_borrow
    item = items(:two)
    submit_with_person :borrow, {
      :person_id => people(:two).id,
      :id => item.id
    }, nil, nil, :get
    assert_response :success
    assert_template 'borrow'
    assert_not_nil assigns(:person)
    assert_not_nil assigns(:item)
  end
  
  def test_thank_for
    submit_with_person :thank_for, { 
      :person_id => people(:one),
      :id => items(:two).id
    }, nil, nil, :get
    assert_response :success
    assert_template 'thank_for'  
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:person)
    assert_not_nil assigns(:kassi_event)
    assert_not_nil assigns(:people)
  end
  
  def test_mark_as_borrowed
    item = items(:two)
    submit_with_person :mark_as_borrowed, { 
      :person_id => people(:two),
      :id => item.id,
      :kassi_event => {
        :realizer_id => people(:two),
        :eventable_id => item.id,
        :eventable_type => "Item",
        :comment => "Kommentti"
      }  
    }, :kassi_event, :receiver_id, :post
    assert_redirected_to people(:two)
    assert ! assigns(:kassi_event).new_record?
    assert_equal "Kommentti", assigns(:kassi_event).person_comments.first.text_content
  end

end
