class MessagesController < ApplicationController

  before_filter :logged_in

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
          PersonConversation.find(:all, :conditions => "conversation_id = '" + @conversation.id.to_s + "'").each do |person_conversation|
            if person_conversation.person.id == @current_user.id
              person_conversation.update_attribute(:last_sent_at, @message.created_at)
            else  
              person_conversation.update_attributes({ :is_read => 0, :last_received_at => @message.created_at })
              @receiver = person_conversation.person
            end  
          end
        else
          @receiver = Person.find(params[:message][:receiver_id])
          if params[:message][:listing_id]
            @conversation = Conversation.new(:listing_id => listing.id, :title => params[:message][:title])
          else 
            @conversation = Conversation.new(:title => params[:message][:title])
          end    
          if @conversation.save
            PersonConversation.create(:person_id => @current_user.id, 
                                      :conversation_id => @conversation.id, 
                                      :is_read => 1,
                                      :last_sent_at => @message.created_at)
            PersonConversation.create(:person_id => params[:message][:receiver_id], 
                                      :conversation_id => @conversation.id, 
                                      :last_received_at => @message.created_at)
          else
            @message.destroy
            if @conversation.errors.full_messages.first.to_s.include?("liian")
              flash[:error] = :message_title_is_too_long
            else  
              flash[:error] = :message_must_have_title
            end  
            redirect_to :back and return
          end                              
        end  
        @conversation.messages << @message
        if RAILS_ENV != "development" && @receiver.settings.email_when_new_message == 1
          UserMailer.deliver_notification_of_new_message(@receiver, @message, session[:cookie])
        end  
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
  
end
