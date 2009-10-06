require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  
  def test_show
    get :show, :id => "all_categories"
    assert_response :success
    assert_template 'listings/index'
    assert_equal [listings(:fourth_valid_listing), listings(:another_valid_listing), listings(:valid_listing)], assigns(:listings)
    
    get :show, :id => "sell"
    assert_response :success
    assert_template 'listings/index'
    assert_equal assigns(:listings), [listings(:valid_listing)]
    
    get :show, :id => "others"
    assert_response :success
    assert_template 'listings/index'
    assert_equal assigns(:listings), [listings(:another_valid_listing)]
  end
  
end
