require 'test_helper'

class ConversationsControllerTest < ActionController::TestCase
  
  def setup
    @test_person1, @session1 = get_test_person_and_session("kassi_testperson1")
    @test_person2, @session2 = get_test_person_and_session("kassi_testperson2")
  end
  
  def test_show_inbox
    submit_with_person :index, {
      :person_id => people(:one).id
    }, nil, nil, :get
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:person_conversations)
    assert_equal 0, assigns(:person_conversations).size
  end
  
  def test_show_sent_mail
    submit_with_person :sent, {
      :person_id => people(:one).id
    }, nil, nil, :get
    assert_response :success
    assert_template 'sent'
    assert_not_nil assigns(:person_conversations)
    assert_equal 0, assigns(:person_conversations).size
  end
  
  # Doesn't work: session variable is not handled properly
  # def test_show_conversation
  #   puts conversations(:one).person_conversations.inspect
  #   submit_with_person :show, {
  #     :person_id => people(:one).id,
  #     :id => conversations(:one).id
  #   }, nil, nil, :get
  #   assert_response :success
  #   assert_template 'show'
  #   assert_not_nil assigns(:conversation)
  #   assert_not_nil assigns(:message)
  #   assert_equal assings(:listing), listings(:valid_listing)
  # end
  
  # Doesn't work: session variable is not handled properly
  # def test_edit_conversation
  #   puts conversations(:one).person_conversations.inspect
  #   submit_with_person :edit, {
  #     :person_id => people(:one).id,
  #     :id => conversations(:one).id
  #   }, nil, nil, :get
  #   assert_response :success
  #   assert_template 'show'
  #   assert_not_nil assigns(:conversation)
  #   assert_not_nil assigns(:message)
  #   assert_equal assings(:listing), listings(:valid_listing)
  # end
  
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
        :conversation_participants => [[people(:one).id, 1], [people(:two).id, 0]],
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
    assert_equal conversation.participants, [ people(:one), people(:two) ]
    assert_equal 1, conversation.person_conversations.find_by_person_id(people(:one).id).is_read
    assert_equal 0, conversation.person_conversations.find_by_person_id(people(:two).id).is_read
    assert_equal conversation.listing, listing
    assert_redirected_to return_path
  end

  def test_create_new_free_conversation
    return_path = people_path
    submit_with_person :create, { 
      :conversation => {
        :conversation_participants => [[people(:one).id, 1], [people(:two).id, 0]],
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
    assert_equal conversation.participants, [ people(:one), people(:two) ]
    assert_equal 1, conversation.person_conversations.find_by_person_id(people(:one).id).is_read
    assert_equal 0, conversation.person_conversations.find_by_person_id(people(:two).id).is_read
    assert_redirected_to return_path
  end
  
  def test_post_to_existing_conversation
    submit_with_person :update, { 
      :conversation => {
        :message_attributes => { :content => "testing", :sender_id => people(:one).id }
      },
      :person_id => people(:one).id,
      :id => conversations(:one).id
    }, :conversation, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], :message_sent
    conversation = assigns(:conversation)
    assert_equal 3, conversation.messages.size
    assert_equal "testing", conversation.last_message.content
    assert_equal conversation.last_message.sender, people(:one)
    assert_redirected_to person_inbox_path(people(:one), conversation)
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
  
  def test_create_new_reservation
    return_path = people_path
    submit_with_person :create, {
      :conversation => {
        :conversation_participants => [[people(:one).id, 1], [people(:two).id, 0]],
        :title => "Reservation",
        :message_attributes => { :content => "I want to reserve these", :sender_id => people(:one).id },
        :reserved_items => get_reserved_items(2),
        :type => "Reservation",
        :pick_up_time => Time.now + 10.days,
        :return_time => Time.now + 12.days,
        :status => "pending_owner",  
      },
      :receiver => people(:two).id,
      :return_to => return_path,
      :person_id => people(:one).id
    }, :conversation, nil
    assert_response :found, @response.body
    assert_equal flash[:notice], :message_sent
    conversation = assigns(:conversation)
    assert ! conversation.new_record?
    assert ! conversation.last_message.new_record?
    assert_equal conversation.last_message.sender, people(:one)
    assert_equal conversation.title, "Reservation"
    assert_equal conversation.type, "Reservation"
    assert_equal conversation.participants, [ people(:one), people(:two) ]
    assert_equal 1, conversation.person_conversations.find_by_person_id(people(:one).id).is_read
    assert_equal 0, conversation.person_conversations.find_by_person_id(people(:two).id).is_read
    assert_equal conversation.items, people(:two).items
    assert_equal 2, conversation.item_reservations.first.amount
    assert_redirected_to return_path
  end
  
  def test_create_invalid_reservation
    return_path = people_path
    submit_with_person :create, {
      :conversation => {
        :conversation_participants => [people(:one).id, people(:two).id],
        :message_attributes => { :sender_id => people(:one).id },
        :title => "Reservation",
        :reserved_items => get_reserved_items(5),
        :type => "Reservation",
        :pick_up_time => DateTime.now + 2.hours,
        :return_time => DateTime.now,
        :status => "pending_owner",  
      },
      :receiver => people(:two).id,
      :return_to => return_path,
      :person_id => people(:one).id
    }, :conversation, nil
    assert_response :success, @response.body
    assert assigns(:conversation).errors.on(:messages)
    assert assigns(:conversation).errors.on(:return_time)
    assert_equal 0, assigns(:conversation).items.size
    assert_template "borrow"
  end
  
  def test_change_reservation
    submit_with_person :update, { 
      :conversation => {
        :reserved_items => get_reserved_items(1),
        :pick_up_time => DateTime.now + 5.hours,
        :return_time => DateTime.now + 6.hours,
        :status => "pending_owner", 
      },
      :person_id => people(:one).id,
      :id => conversations(:three).id
    }, :conversation, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], :borrow_request_edited
    conversation = assigns(:conversation)
    assert_equal "pending_owner", conversation.status
    assert_equal 1, conversation.item_reservations.first.amount
    assert_redirected_to person_inbox_path(people(:one), conversation)
  end
  
  def test_accept_reservation
    submit_with_person :update, { 
      :conversation => {
        :status => "accepted", 
      },
      :kassi_event => {
        :eventable_id => conversations(:three).id,
        :eventable_type => "Reservation",
        :participant_attributes => {
          people(:one).id => "provider",
          people(:two).id => "requester"
        }
      },
      :accepted => "accepted",
      :person_id => people(:one).id,
      :id => conversations(:three).id
    }, :conversation, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], "borrow_request_accepted"
    conversation = assigns(:conversation)
    assert_equal "accepted", conversation.status
    kassi_event = assigns(:kassi_event)
    assert ! kassi_event.new_record?
    assert_equal people(:two), kassi_event.requester
    assert_equal people(:one), kassi_event.provider
    assert_redirected_to person_inbox_path(people(:one), conversation)
  end
  
  def test_reject_reservation
    submit_with_person :update, { 
      :conversation => {
        :status => "rejected", 
      },
      :person_id => people(:one).id,
      :id => conversations(:three).id
    }, :conversation, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], "borrow_request_rejected"
    conversation = assigns(:conversation)
    assert_equal "rejected", conversation.status
    assert_redirected_to person_inbox_path(people(:one), conversation)
  end
  
  def test_create_new_favor_request
    return_path = people_path
    submit_with_person :create, {
      :conversation => {
        :conversation_participants => [[people(:one).id, 1], [people(:two).id, 0]],
        :title => "Favor request",
        :message_attributes => { :content => "I want to ask for this favor", :sender_id => people(:one).id },
        :favor_id => favors(:two).id,
        :type => "FavorRequest",
        :status => "pending",  
      },
      :receiver => people(:two).id,
      :return_to => return_path,
      :person_id => people(:one).id
    }, :conversation, nil
    assert_response :found, @response.body
    assert_equal flash[:notice], :message_sent
    conversation = assigns(:conversation)
    assert ! conversation.new_record?
    assert ! conversation.last_message.new_record?
    assert_equal conversation.last_message.sender, people(:one)
    assert_equal conversation.title, "Favor request"
    assert_equal conversation.type, "FavorRequest"
    assert_equal conversation.participants, [ people(:one), people(:two) ]
    assert_equal 1, conversation.person_conversations.find_by_person_id(people(:one).id).is_read
    assert_equal 0, conversation.person_conversations.find_by_person_id(people(:two).id).is_read
    assert_equal conversation.favor, favors(:two)
    assert_redirected_to return_path
  end
  
  def test_create_invalid_favor_request
    return_path = people_path
    submit_with_person :create, {
      :conversation => {
        :conversation_participants => [people(:one).id, people(:two).id],
        :message_attributes => { :sender_id => people(:one).id },
        :favor_id => favors(:two).id, 
        :title => "Favor request",
        :type => "FavorRequest",
        :status => "pending",  
      },
      :receiver => people(:two).id,
      :return_to => return_path,
      :person_id => people(:one).id
    }, :conversation, nil
    assert_response :success, @response.body
    assert assigns(:conversation).errors.on(:messages)
    assert_template "ask_for"
  end
  
  def test_accept_favor_request
    submit_with_person :update, { 
      :conversation => {
        :status => "accepted", 
      },
      :kassi_event => {
        :eventable_id => conversations(:four).id,
        :eventable_type => "FavorRequest",
        :participant_attributes => {
          people(:one).id => "provider",
          people(:two).id => "requester"
        }
      },
      :accepted => "accepted",
      :person_id => people(:one).id,
      :id => conversations(:four).id
    }, :conversation, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], "favor_request_accepted"
    conversation = assigns(:conversation)
    assert_equal "accepted", conversation.status
    kassi_event = assigns(:kassi_event)
    assert ! kassi_event.new_record?
    assert_equal people(:two), kassi_event.requester
    assert_equal people(:one), kassi_event.provider
    assert_redirected_to person_inbox_path(people(:one), conversation)
  end
  
  def test_reject_favor_request
    submit_with_person :update, { 
      :conversation => {
        :status => "rejected", 
      },
      :person_id => people(:one).id,
      :id => conversations(:four).id
    }, :conversation, nil, :put
    assert_response :found, @response.body
    assert_equal flash[:notice], "favor_request_rejected"
    conversation = assigns(:conversation)
    assert_equal "rejected", conversation.status
    assert_redirected_to person_inbox_path(people(:one), conversation)
  end
  
  private
  
  def get_reserved_items(amount)
    reserved_items = {}
    people(:two).items.each do |item|
      reserved_items[item.id.to_s] = amount
    end
    return reserved_items
  end  
  
end
