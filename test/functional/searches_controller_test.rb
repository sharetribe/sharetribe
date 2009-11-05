require 'test_helper'

class SearchesControllerTest < ActionController::TestCase

  def test_search_all
    search("sdfsdfjiji", 0, 0, 0, 0, 0)
    search("*", 3, 2, 2, 0, 0)
    search("Testperson", 0, 0, 0, 1, 0)
    search("Testgroup", 0, 0, 0, 0, 2)
  end
  
  private
  
  def search(query, listings_count, items_count, favors_count, people_count, group_count)
    get :show, :qa => query
    assert_response :success
    assert_equal listings_count, assigns(:listing_amount)
    assert_equal items_count, assigns(:items).size
    assert_equal favors_count, assigns(:favors).size
    assert_equal people_count, assigns(:people).size
    assert_equal group_count, assigns(:groups).size
    assert_template 'show'
  end

end
