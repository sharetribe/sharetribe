class ConversationsController < ApplicationController

  before_filter :logged_in

  # Shows inbox
  def index
    fetch_messages
  end
  
  # Shows sent-mail_box
  def sent
    fetch_messages(true)
  end  

  # Shows one conversation 
  def show
    @conversation = Conversation.find(params[:id])
    person_conversation = PersonConversation.find_by_conversation_id_and_person_id(@conversation.id, @current_user.id)
    if person_conversation.is_read == 0
      @inbox_new_count -= 1
      person_conversation.update_attribute(:is_read, 1)
    end  
    @next_conversation = Conversation.find(:first, :conditions => ["updated_at > ?", @conversation.updated_at]) || @conversation
    @previous_conversation = Conversation.find(:last, :conditions => ["updated_at < ?", @conversation.updated_at]) || @conversation
    @listing = @conversation.listing if @conversation.listing
    @message = Message.new
  end

  # Creates new message and adds it to an existing conversation or creates a new conversation.
  def create
    if params[:message][:cancel]
      if params[:message][:listing_id]     
        redirect_to listing_path(params[:message][:listing_id])
      else
        redirect_to person_path(params[:message][:receiver_id])  
      end
    else    
      @message = Message.new(params[:message])
      if @message.save
        if params[:message][:current_conversation]
          @conversation = Conversation.find(params[:message][:current_conversation])
        elsif params[:message][:listing_id]   
          listing = Listing.find(params[:message][:listing_id])
          @current_user.conversations.each do |conversation|
            if conversation.listing && conversation.listing.id == listing.id
              @conversation = conversation 
            end  
          end
        end    
        if @conversation
          unless @conversation.title.index('RE: ') == 0
            @conversation.update_attribute(:title, "RE: " +  @conversation.title)
          end  
          PersonConversation.find(:all, :conditions => "conversation_id = '" + @conversation.id.to_s + "' AND person_id <> '" + @current_user.id + "'").each do |person_conversation|
            person_conversation.update_attribute(:is_read, 0) 
          end
        else
          if params[:message][:listing_id]  
            @conversation = Conversation.new(:listing_id => listing.id, :title => params[:message][:title])
          else 
            @conversation = Conversation.new(:title => params[:message][:title])
          end    
          @conversation.save
          PersonConversation.create(:person_id => @current_user.id, :conversation_id => @conversation.id, :is_read => 1)
          Person.find(params[:message][:receiver_id]).conversations << @conversation
        end  
        @conversation.messages << @message
        flash[:notice] = :message_sent
        if params[:message][:current_conversation]
          redirect_to person_inbox_path(@current_user, params[:message][:current_conversation])
        elsif params[:message][:listing_id]     
          redirect_to listing_path(listing)
        else
          redirect_to person_path(params[:message][:receiver_id])  
        end  
      else
        flash[:error] = :message_could_not_be_sent
        redirect_to :back
      end
    end    
  end

  private
  
  # Gets all messages for inbox or sent-mail-box.
  def fetch_messages(is_sent_mail = false)
    save_navi_state(['own','inbox','',''])
    person_conversations = []
    PersonConversation.find(:all, :conditions => "person_id = '" + @current_user.id + "'").each do |person_conversation|
      conversation_ok = false
      person_conversation.conversation.messages.each do |message|
        if is_sent_mail
          if message.sender == @current_user
            conversation_ok = true
          end  
        else  
          unless message.sender == @current_user
            conversation_ok = true
          end
        end          
      end
      if conversation_ok
        person_conversations << person_conversation
      end  
    end    
    @person_conversations = person_conversations.sort { 
      |b,a| a.conversation.updated_at <=> b.conversation.updated_at 
    }.paginate :page => params[:page], :per_page => per_page
  end

end
