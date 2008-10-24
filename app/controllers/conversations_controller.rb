class ConversationsController < ApplicationController

  before_filter :logged_in

  def index
    fetch_messages
  end
  
  def sent
    
  end  

  def show
    @conversation = Conversation.find(params[:id])
    PersonConversation.find_by_conversation_id_and_person_id(@conversation.id, @current_user.id).update_attribute(:is_read, 1)
    @inbox_new_count -= 1
    @next_conversation = Conversation.find(:first, :conditions => ["updated_at > ?", @conversation.updated_at]) || @conversation
    @previous_conversation = Conversation.find(:last, :conditions => ["updated_at < ?", @conversation.updated_at]) || @conversation
    @listing = @conversation.listing
    @message = Message.new
  end

  # Creates new message and adds it to an existing conversation or creates a new conversation.
  def create
    @message = Message.new(params[:message])
    if @message.save
      listing = Listing.find(params[:message][:listing_id])
      @current_user.conversations.each do |conversation|
        if conversation.listing.id == listing.id
          @conversation = conversation
          PersonConversation.find(:all, :conditions => "conversation_id = '" + @conversation.id.to_s + "' AND person_id <> '" + @current_user.id + "'").each do |person_conversation|
            person_conversation.update_attribute(:is_read, 0) 
          end  
        end  
      end  
      unless @conversation
        @conversation = Conversation.new(:listing_id => listing.id, :title => params[:message][:title])
        @conversation.save
        PersonConversation.create(:person_id => @current_user.id, :conversation_id => @conversation.id, :is_read => 1)
        Person.find(params[:message][:receiver_id]).conversations << @conversation
      end  
      @conversation.messages << @message
      flash[:notice] = :reply_sent
      if params[:message][:current_conversation]
        redirect_to person_inbox_path(@current_user, params[:message][:current_conversation])
      else     
        redirect_to listing_path(listing)
      end  
    else
      flash[:error] = :reply_could_not_be_sent
      render :template => "listings/reply"
    end    
  end

  private
  
  def fetch_messages(is_sent_mail = false)
    save_navi_state(['own','inbox','',''])
    person_conversations = []
    PersonConversation.find(:all, :conditions => "person_id = '" + @current_user.id + "'").each do |person_conversation|
      conversation_ok = false
      person_conversation.conversation.messages.each do |message|
        unless message.sender == @current_user
          conversation_ok = true
        end        
      end
      if conversation_ok
        person_conversations << person_conversation
      end  
    end    
    @person_conversations = person_conversations.sort{ |b,a| a.conversation.updated_at <=> b.conversation.updated_at }
  end

end
