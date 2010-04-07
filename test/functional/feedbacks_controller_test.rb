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
    submit_with_person :index, {}, nil, nil, :get
    assert_response :success
    assert_template 'index'
    assert_equal 2, assigns(:feedbacks).size
    assert_equal 1, assigns(:new_feedback_item_amount)
  end
  
  def test_add_feedback
    submit_with_person :create, { :feedback => {
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
  
  def test_spam_feedback
    post :create, :feedback => {
      :url => listings_path,
      :content => "CVeGt  <a href=\"http://uputuxsnvsma.com/\">uputuxsnvsma</a>, [url=http://gsagyagrqqok.com/]gsagyagrqqok[/url], [link=http://igvysiydxsyy.com/]igvysiydxsyy[/link], http://zppdjmneyhmn.com/"
    }
    assert_response :found, @response.body
    assert assigns(:feedback).new_record?
    assert_nil flash[:notice]
    assert_not_nil flash[:error]
    
  end
  
  
  def test_handle_feedback
    @request.env['HTTP_REFERER'] = admin_feedbacks_path
    feedback = feedbacks(:one)
    assert_equal 0, feedback.is_handled
    submit_with_person :handle, { 
      :id => feedback.id
    }, nil, nil, :put
    assert_redirected_to admin_feedbacks_path
  end
  
end
