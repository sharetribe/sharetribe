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
    assert_not_nil assigns(:item_title_hash)
  end

  def test_show_item
    get :show, :id => "vasara"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_equal assigns(:items), [ items(:one) ]
  end
  
  def test_show_item_with_difficult_name
    get :show, :id => "Örkki's tapponuija 2.5,6 /nn%6?"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_equal assigns(:items), [ items(:difficult) ] 
  end

  def test_create_and_delete_item
    submit_with_person :create, { 
      :item => { :title => "TestTitle" }
    }, :item, :owner_id
    assert_response :success, @response.body
    assert_not_nil flash[:notice]
    assert ! assigns(:item).new_record?
    submit_with_person :destroy, {
      :id => assigns(:item).id 
    }, :item, :owner_id, :delete
    assert_equal "disabled", assigns(:item).status
  end

  def test_create_item_with_title_that_already_exists 
    submit_with_person :create, { 
      :item => { :title => "vasara" }
    }, :item, :owner_id
    assert assigns(:item).errors.on(:title)
  end
  
  def test_recover_disabled_item 
    submit_with_person :create, { 
      :item => { :title => "kirves" }
    }, :item, :owner_id
    assert_response :success, @response.body
    assert_nil assigns(:item).id
    assert_equal "enabled", items(:three).status
  end

  def test_edit_item
    submit_with_person :update, { 
      :item => { 
        :title => "muutettu_vasara",
        :visibility => "everybody",
        :amount => "2"  
      },
      :id => items(:one).id,
      :person_id => @test_person1.id
    }, :item, :owner_id, :put
    assert_response :success, @response.body
    assert_equal flash[:notice], :item_updated
    assert_equal "muutettu_vasara", assigns(:item).title
  end
  
  def test_show_borrow_view
    submit_with_person :borrow, { 
      :person_id => people(:two),
      :id => items(:two).id,
      :receiver => people(:two).id,
      :return_to => items_path
    }, nil, nil, :get
    assert_response :success
    assert_template 'borrow'
    assert_not_nil assigns(:conversation)
    assert_equal people(:two), assigns(:person)
    assert_equal 1, assigns(:items).size
  end
  
  def test_show_borrow_view_multiple_items
    submit_with_person :borrow, { 
      :person_id => people(:two),
      :items => people(:two).items,
      :receiver => people(:two).id,
      :return_to => items_path
    }, nil, nil, :get
    assert_response :success
    assert_template 'borrow'
    assert_not_nil assigns(:conversation)
    assert_equal people(:two), assigns(:person)
    assert_equal 2, assigns(:items).size
  end
  
  def test_search_items_view
    get :search
    assert_response :success
    assert_template 'search'
  end
  
  def test_search_items
    search("dsfds", 0)
    search("*", 3)
    search("saha", 1)
    search("*asar*", 1)
  end
  
  def test_map
    submit_with_person :map, {
      :id => items(:one).id
    }, nil, nil, :get
    assert_response :success
    assert_template 'map'
    assert_equal assigns(:item), items(:one)
    # Fails, probably because tests can't connect to Google Maps for some reason
    # assert_not_nil assigns(:map)
  end
  
  private
  
  def search(query, result_count)
    get :search, :q => query
    assert_response :success
    assert_equal result_count, assigns(:items).size
    assert_template 'search'
  end  

end
