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
  
  def test_show_new_free_message_form
    submit_with_person :new, {
      :return_to => people_path,
      :receiver => people(:two).id,
      :person_id => people(:one).id
    }, nil, nil, :get
    assert_template "new"
    assert_equal people(:two), assigns(:receiver)
  end
  
  def test_show_reply_to_listing_form
    listing = listings(:third_valid_listing)
    submit_with_person :new, {
      :return_to => listings_path,
      :target_object => listing.id,
      :target_object_type => "listing",
    }, nil, nil, :get
    assert_template "new"
    assert_equal listing, assigns(:target_object)
  end
  
  def test_show_ask_for_favor_form
    favor = favors(:two)
    submit_with_person :new, {
      :return_to => favors_path,
      :target_object => favor.id,
      :target_object_type => "favor",
    }, nil, nil, :get
    assert_template "new"
    assert_equal favor, assigns(:target_object)
  end
  
  def test_create_new_listing_based_conversation
    listing = listings(:third_valid_listing)
    return_path = listings_path
    submit_with_person :create, { 
      :conversation => {
        :conversation_participants => [people(:one).id, people(:two).id],
        :title => "RE: " + listing.title,
        :listing_id => listing.id,
        :message_attributes => { :content => "test content", :sender_id => people(:one).id }
      },
      :target_object => listing.id,
      :target_object_type => "listing",
      :return_to => return_path,
      :person_id => people(:one).id
    }, :conversation, nil
    assert_response :found, @response.body
    assert_equal flash[:notice], :message_sent
    conversation = assigns(:conversation)
    assert ! conversation.new_record?
    assert ! conversation.last_message.new_record?
    assert_equal conversation.last_message.sender, people(:one)
    assert_equal conversation.title, "RE: " + listing.title
    assert_equal conversation.participants, [ people(:two), people(:one) ]
    assert_equal conversation.listing, listing
    assert_redirected_to return_path
  end

  def test_create_new_free_conversation
    return_path = people_path
    submit_with_person :create, { 
      :conversation => {
        :conversation_participants => [people(:one).id, people(:two).id],
        :title => "Tsuibaduiba",
        :message_attributes => { :content => "test content", :sender_id => people(:one).id }
      },
      :return_to => return_path,
      :person_id => people(:one).id
    }, :conversation, nil
    assert_response :found, @response.body
    assert_equal flash[:notice], :message_sent
    conversation = assigns(:conversation)
    assert ! conversation.new_record?
    assert ! conversation.last_message.new_record?
    assert_equal conversation.last_message.sender, people(:one)
    assert_equal conversation.title, "Tsuibaduiba"
    assert_equal conversation.participants, [ people(:two), people(:one) ]
    assert_redirected_to return_path
  end
  
  def test_create_invalid_conversation
    return_path = people_path
    submit_with_person :create, { 
      :conversation => {
        :conversation_participants => [people(:one).id, people(:two).id],
        :message_attributes => { :sender_id => people(:one).id }
      },
      :receiver => people(:two).id,
      :return_to => return_path,
      :person_id => people(:one).id
    }, :conversation, nil
    assert assigns(:conversation).errors.on(:title)
    assert assigns(:conversation).errors.on(:messages)
    assert_template "new"
  end
  
end
