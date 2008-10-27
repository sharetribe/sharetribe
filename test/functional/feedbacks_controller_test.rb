require 'test_helper'

class Admin::FeedbacksControllerTest < ActionController::TestCase
  
  def setup
    @test_person, @session = get_test_person_and_session
    @cookie = @session.cookie
  end
  
  def teardown
    @session.destroy
  end
  
  def test_show_index
    get_logged_in :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:feedbacks)
  end

  def test_add_feedback
    post_with_author :create, { :feedback => {
      :content => "Testisisältö",
      :url => "/listings"
    }}, :feedback
    assert_response :found, @response.body
    assert ! assigns(:feedback).new_record?
    assert_not_nil flash[:notice]
  end
  
  def test_add_invalid_feedback
    post :create, :feedback => {
      :url => listings_path
    }
    assert assigns(:feedback).errors.on(:author_id)
    assert assigns(:feedback).errors.on(:content)
  end
  
end
