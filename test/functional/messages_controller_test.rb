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
  
  # TODO: This can be done after redirect_to :back can be tested
  # def test_create_invalid_message
  #   submit_with_person :create, { :message => {} }, :message, :sender_id
  #   assert assigns(:listing).errors.on(:content)
  # end
  
end
