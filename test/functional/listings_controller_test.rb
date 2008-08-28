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
    image = uploaded_file("Bison_skull_pile.png", "image/png")
    post :create, :listing => {
      :author_id => "Antti",
      :category => "sell",
      :title => "Myydään alastomia oravoita",
      :content => "Title says it all.",
      :good_thru => DateTime.now+(2),
      :times_viewed => 32,
      :status => "open",
      :language_fi => 1,
      :language_swe => 1,
      :image_file => image
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
  
  def test_add_invalid_image_to_listing
    image = uploaded_file("i_am_not_image.txt", "text/plain")
    post :create, :listing => {
      :author_id => "Antti",
      :category => "sell",
      :title => "Myydään alastomia oravoita",
      :content => "Title says it all.",
      :good_thru => DateTime.now+(2),
      :times_viewed => 32,
      :status => "open",
      :language_fi => 1,
      :language_swe => 1,
      :image_file => image
    }
  end
  
  def test_delete_image_file
    
  end
  
  def test_show_listing
    get :show, :id => listings(:valid_listing)
    assert_response :success
    assert_template 'show'
    assert_equal listings(:valid_listing), assigns(:listing)
  end
  
end
