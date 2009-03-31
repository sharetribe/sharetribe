require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
  end
  
  def test_create_new_listing_based_conversation
    submit_with_person :create, { :message => {
      :receiver_id => people(:two).id,
      :listing_id => listings(:third_valid_listing).id,
      :title => "RE: " + listings(:third_valid_listing).title,
      :content => "test content"
    }}, :message, :sender_id
    assert_response :found, @response.body
    assert_not_nil flash[:notice]
    message = assigns(:message)
    assert ! message.new_record?
    assert ! message.conversation.new_record?
    assert_equal message.sender, people(:one)
    assert_equal message.conversation.title, "RE: " + listings(:third_valid_listing).title
    assert_equal message.conversation.participants, [ people(:one), people(:two) ]
    assert_equal message.conversation.listing, listings(:third_valid_listing)
  end

  def test_create_new_free_conversation
    submit_with_person :create, { :message => {
      :receiver_id => people(:two).id,
      :title => "test title",
      :content => "test content"
    }}, :message, :sender_id
    assert_response :found, @response.body
    assert_not_nil flash[:notice]
    message = assigns(:message)
    assert ! message.new_record?
    assert ! message.conversation.new_record?
    assert_equal message.sender, people(:one)
    assert_equal message.conversation.title, "test title"
    assert_equal message.conversation.participants, [ people(:one), people(:two) ]
    assert !message.conversation.listing
  end
  
  def test_post_to_existing_conversation
    conversation = conversations(:one)
    submit_with_person :create, { :message => {
      :current_conversation => conversation.id,
      :content => "test reply"
    }}, :message, :sender_id
    assert_response :found, @response.body
    assert_not_nil flash[:notice]
    message = assigns(:message)
    assert ! message.new_record?
    assert_equal message.sender, people(:one)
    assert_equal message.conversation.title, "RE: Test title"
    assert_equal conversation.messages, [ messages(:valid_message), messages(:two), message]
  end
  
  def test_create_message_with_no_content
    @request.env['HTTP_REFERER'] = send_message_person_path(people(:one))
    submit_with_person :create, { :message => {} }, :message, :sender_id
    assert assigns(:message).errors.on(:content)
    assert_equal :message_could_not_be_sent, flash[:error]
  end
  
  def test_create_message_with_no_title
    @request.env['HTTP_REFERER'] = send_message_person_path(people(:one))
    submit_with_person :create, { :message => { 
      :receiver_id => people(:two).id, 
      :content => "test_content" 
    }}, :message, :sender_id
    assert_equal :message_must_have_title, flash[:error]
  end
  
end
