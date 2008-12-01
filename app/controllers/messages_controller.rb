class MessagesController < ApplicationController

  before_filter :logged_in

  # Creates new message and adds it to an existing conversation or creates a new conversation.
  def create
    if params[:message][:cancel]
      if params[:message][:listing_id]     
        redirect_to listing_path(params[:message][:listing_id])
      elsif params[:message][:item_id]
        if session[:previous_page]
          redirect_to session[:previous_page]
        else  
          redirect_to person_path(params[:message][:receiver_id]) 
        end  
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
            end  
          end
        else
          if params[:message][:listing_id]  
            @conversation = Conversation.new(:listing_id => listing.id, :title => params[:message][:title])
          else 
            @conversation = Conversation.new(:title => params[:message][:title])
          end    
          @conversation.save
          PersonConversation.create(:person_id => @current_user.id, 
                                    :conversation_id => @conversation.id, 
                                    :is_read => 1,
                                    :last_sent_at => @message.created_at)
          PersonConversation.create(:person_id => params[:message][:receiver_id], 
                                    :conversation_id => @conversation.id, 
                                    :last_received_at => @message.created_at)
        end  
        @conversation.messages << @message
        flash[:notice] = :message_sent
        if params[:message][:current_conversation]
          redirect_to person_inbox_path(@current_user, params[:message][:current_conversation])
        elsif params[:message][:listing_id]     
          redirect_to listing_path(listing)
        else
          if session[:previous_page]
            redirect_to session[:previous_page]
          else  
            redirect_to person_path(params[:message][:receiver_id]) 
          end  
        end  
      else
        flash[:error] = :message_could_not_be_sent
        redirect_to :back
      end
    end    
  end
  
end
