require 'test_helper'

class ListingsControllerTest < ActionController::TestCase
  
  def test_show_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:listings)
  end
  
  def test_show_new_category
    get :new_category
    assert_response :success
    assert_template 'new_category'
  end
  
  def test_show_new
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:listing)
  end
  
  def test_should_show_new_form
    #TODO: test that all the form elements are in their places
  end
  
  def test_add_valid_listing
    post :create, :listing => {
      :author_id => "Antti",
      :category => "sell",
      :title => "Myydään alastomia oravoita",
      :content => "Title says it all.",
      :good_thru => DateTime.now+(2),
      :times_viewed => 32,
      :status => "open",
      :language => ["fi"],
      :value_cc => "8",
      :value_other => "Oravannahkoja"
    }
    assert ! assigns(:listing).new_record?
    assert_redirected_to listings_path
    assert_not_nil flash[:notice]
  end
  
  def test_add_invalid_listing
    post :create, :listing => {
          :author_id => "Antti"
    }
    assert assigns(:listing).errors.on(:category)
    assert assigns(:listing).errors.on(:title)
    assert assigns(:listing).errors.on(:content)
    assert assigns(:listing).errors.on(:good_thru)
    assert assigns(:listing).errors.on(:status)
    assert assigns(:listing).errors.on(:language)
  end
  
end
