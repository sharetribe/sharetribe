class ConversationsController < ApplicationController

  before_filter :logged_in

  # Shows inbox
  def index
    @pagination_type = "inbox"
    fetch_messages
  end
  
  # Shows sent-mail_box
  def sent
    @pagination_type = "sent_messages"
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
    session[:ids].sort! {
      |b,a| session[:dates][a] <=> session[:dates][b]
    }
    if session[:is_sent_mail]
      next_id = session[:ids].reject {|id| session[:dates][id] <= person_conversation.last_sent_at }.last
      previous_id = session[:ids].reject {|id| session[:dates][id] >= person_conversation.last_sent_at }.first
    else 
      next_id = session[:ids].reject {|id| session[:dates][id] <= person_conversation.last_received_at }.last
      previous_id = session[:ids].reject {|id| session[:dates][id] >= person_conversation.last_received_at }.first
    end    
    @next_conversation = next_id ? PersonConversation.find(next_id).conversation : @conversation
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
    session[:is_sent_mail] = is_sent_mail
    save_message_collection_to_session(person_conversations)
    @person_conversations = person_conversations.paginate :page => params[:page], :per_page => per_page
  end

end
