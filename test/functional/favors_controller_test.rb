require 'test_helper'

class FavorsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_show_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:favors_all)
    assert_not_nil assigns(:favor_titles)
  end
end
