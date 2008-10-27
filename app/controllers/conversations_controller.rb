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
