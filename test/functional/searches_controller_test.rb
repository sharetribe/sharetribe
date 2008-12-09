require 'test_helper'

class SearchesControllerTest < ActionController::TestCase

  def test_search_items
    search("sdfsdfjiji", 0, 0, 0)
    search("*", 2, 2, 2)
  end
  
  private
  
  def search(query, listings_count, items_count, favors_count)
    get :show, :qa => query
    assert_response :success
    assert_equal listings_count, assigns(:listing_amount)
    assert_equal items_count, assigns(:items).size
    assert_equal favors_count, assigns(:favors).size
    assert_template 'show'
  end

end
