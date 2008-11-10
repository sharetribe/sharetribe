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
    next_id = session[:ids].reject {|id| id <= params[:id].to_i }.last
    @next_conversation = next_id ? PersonConversation.find(next_id).conversation : @conversation
    previous_id = session[:ids].reject {|id| id >= params[:id].to_i }.first
    @previous_conversation = previous_id ? PersonConversation.find(previous_id).conversation : @conversation
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
    if is_sent_mail
      person_conversations.sort! { 
        |b,a| a.last_sent_at <=> b.last_sent_at
      }
    else
      person_conversations.sort! { 
        |b,a| a.last_received_at <=> b.last_received_at
      }
    end    
    save_collection_to_session(person_conversations)
    @person_conversations = person_conversations.paginate :page => params[:page], :per_page => per_page
  end

end
