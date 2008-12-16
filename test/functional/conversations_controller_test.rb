require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
  end
  
  def show_inbox
    submit_with_person :index, {
      :person_id => people(:one).id
    }, nil, nil, :get
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:person_conversations)
    assert_equal 0, assigns(:person_conversations).size
  end
  
  def show_sent_mail
    submit_with_person :index, {
      :person_id => people(:one).id
    }, nil, nil, :get
    assert_response :success
    assert_template 'sent'
    assert_not_nil assigns(:person_conversations)
    assert_equal assigns(:person_conversations).first, conversations(:one)
  end
  
  def show_conversation
    submit_with_person :show, {
      :person_id => people(:one).id,
      :id => conversations(:one).id
    }, nil, nil, :get
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:conversation)
    assert_not_nil assigns(:message)
    assert_equal assings(:listing), listings(:valid_listing)
  end
  
end
