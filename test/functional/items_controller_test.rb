require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
   def test_show_index
     get :index
     assert_response :success
     assert_template 'index'
     assert_not_nil assigns(:items_all)
     assert_not_nil assigns(:item_titles)
   end

end
