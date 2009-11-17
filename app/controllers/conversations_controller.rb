class ConversationsController < ApplicationController
  helper :all

  before_filter :logged_in
  
  # Shows inbox
  def index
    @person = Person.find(params[:person_id])
    return unless must_be_current_user(@person)
    fetch_conversations("received")
  end

  # Shows sent-mail_box
  def sent
    @person = Person.find(params[:person_id])
    return unless must_be_current_user(@person)
    fetch_conversations("sent")
  end
  
  # Display a form for a new message to a new conversation
  def new
    unless get_target_object_and_validate
      flash[:error] = :cant_send_message_to_self
      redirect_to params[:return_to] and return
    end  
    @conversation = Conversation.new
    @conversation.messages.build
    @conversation.participants.build
  end
  
  # Create a new conversation and send a message to it
  def create
    if params[:conversation][:type].eql?("Reservation")
      @conversation = Reservation.new(params[:conversation])
    elsif params[:conversation][:type].eql?("FavorRequest")
      @conversation = FavorRequest.new(params[:conversation])
    else
      @conversation = Conversation.new(params[:conversation])
    end  
    if @conversation.save
      @conversation.send_email_to_participants(request)
      flash[:notice] = :message_sent
      redirect_to params[:return_to]
    else
      get_target_object_and_validate
      if params[:conversation][:type].eql?("Reservation")
        @items = Item.find(params[:conversation][:reserved_items].keys, :order => "title")
        @person = Person.find(params[:receiver])
        render :template => "items/borrow"
      elsif params[:conversation][:type].eql?("FavorRequest")
        @favor = Favor.find(params[:conversation][:favor_id])
        @person = Person.find(params[:receiver])
        render :template => "favors/ask_for"
      else
        render :action => :new
      end  
    end  
  end
  
  # Displays edit form. Used only with reservations.
  def edit
    @person = Person.find(params[:person_id])
    return unless must_be_current_user(@person)
    @conversation = Conversation.find(params[:id])
    unless @conversation.is_allowed_to_edit?(@current_user)
      redirect_to person_inbox_path(@current_user, @conversation) and return
    end
    session[:links_panel_navi] = "received" unless ["received", "sent"].include?(session[:links_panel_navi])
    @person_conversations = fetch_conversations(session[:links_panel_navi], :all)  
    @items = @conversation.items
  end
  
  # Send a message to an existing conversation
  def update
    if params[:accepted]
      params[:conversation][:status] = "accepted"
      params[:kassi_event][:pending] = 1
    elsif params[:rejected]
      params[:conversation][:status] = "rejected"
      if "Hyväksytty.".eql?(params[:conversation][:message_attributes][:content])
        params[:conversation][:message_attributes][:content] = "Hylätty."
      elsif "Accepted.".eql?(params[:conversation][:message_attributes][:content])
        params[:conversation][:message_attributes][:content] = "Rejected."
      end  
    end
    @conversation = Conversation.find(params[:id])
    if @conversation.update_attributes(params[:conversation])
      if params[:accepted]
        @kassi_event = KassiEvent.create(params[:kassi_event])
      end  
      @conversation.send_email_to_participants(request)
      if @conversation.type.eql?("Reservation")
        if ["accepted", "rejected"].include?(params[:conversation][:status])
          flash[:notice] = "borrow_request_" + params[:conversation][:status]
        else  
          flash[:notice] = :borrow_request_edited
        end
      elsif @conversation.type.eql?("FavorRequest")
        flash[:notice] = "favor_request_" + params[:conversation][:status]
      else
        flash[:notice] = :message_sent
      end  
      redirect_to person_inbox_path(@current_user, @conversation)
    else
      if (@conversation.type.eql?("Reservation") && params[:conversation][:status] && 
        !["accepted", "rejected"].include?(params[:conversation][:status]))
        flash[:error] = @conversation.errors.full_messages.first
        redirect_to edit_person_inbox_path(@current_user, @conversation)
      else  
        flash[:error] = :message_could_not_be_sent
        redirect_to person_inbox_path(@current_user, @conversation)
      end  
    end
  end  

  # Shows one conversation 
  def show
    @person = Person.find(params[:person_id])
    return unless must_be_current_user(@person)
    session[:links_panel_navi] = "received" unless ["received", "sent"].include?(session[:links_panel_navi])
    @person_conversations = fetch_conversations(session[:links_panel_navi], :all)
    @conversation = Conversation.find(params[:id])
    person_conversation = PersonConversation.find_by_conversation_id_and_person_id(@conversation.id, @current_user.id)
    if person_conversation.is_read == 0
      @inbox_new_count -= 1
      @new_arrived_items_count -= 1
      person_conversation.update_attribute(:is_read, 1)
    end
    index = @person_conversations.index(person_conversation)
    @previous_conversation = (index == @person_conversations.size - 1) ? @conversation : @person_conversations[index + 1].conversation
    @next_conversation = (index == 0) ? @conversation : @person_conversations[index - 1].conversation
    @listing = @conversation.listing if @conversation.listing
  end
  
  private
  
  # Sets target object and title based on parameters given. Also validate that
  # the user is not sending a message to him/herself.
  def get_target_object_and_validate
    is_valid = true
    case params[:target_object_type]
    when "listing"
      @target_object = Listing.find(params[:target_object])
      @title = t(:reply_to_listing) + ' "' + CGI.escapeHTML(@target_object.title) + '"'
      is_valid = false if current_user?(@target_object.author)
    when "favor"
      @target_object = Favor.find(params[:target_object])
      @title = t(:ask_for_favor) + " " + @target_object.title.downcase + " " + t(:from_user) + " " + @target_object.owner.name(session[:cookie])
      is_valid = false if current_user?(@target_object.owner)
    else
      @receiver = Person.find(params[:receiver])
      @title = t(:send_message_to_user) + " " + @receiver.name(session[:cookie])
      is_valid = false if current_user?(@receiver)
    end
    return is_valid
  end
  
  # Returns all conversations based on conversation type (can be "sent" or "received")
  def fetch_conversations(conversation_type, per_page_number = nil)
    save_navi_state(['own', 'inbox', '', '', conversation_type])
    @pagination_type = conversation_type
    @person_conversations = PersonConversation.paginate(:all, 
                                                        :page => params[:page], 
                                                        :per_page => per_page_number || per_page, 
                                                        :conditions => ["person_id LIKE ? AND last_#{conversation_type}_at IS NOT NULL", @current_user.id],
                                                        :order => "last_#{conversation_type}_at DESC")
  end
  
end
