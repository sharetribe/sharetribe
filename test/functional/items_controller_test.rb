require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
   
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
     assert_equal assigns(:items), [ items(:valid_title) ]
   end
   
   def test_create_item
     
   end

end
