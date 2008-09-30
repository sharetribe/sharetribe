class ConversationsController < ApplicationController

  def index
    save_navi_state(['own','inbox','',''])
    @conversations = @current_user.conversations.sort{ |b,a| a.updated_at <=> b.updated_at }
  end  

  def show
    @conversation = Conversation.find(params[:id])
  end

  # Creates new message and adds it to an existing conversation or creates a new conversation.
  def create
    @message = Message.new(params[:message])
    if @message.save
      listing = Listing.find(params[:message][:listing_id])
      @current_user.conversations.each do |conversation|
        if conversation.listing.id == listing.id
          @conversation = conversation
        end  
      end  
      unless @conversation
        @conversation = Conversation.new(:listing_id => listing.id, :title => params[:message][:title])
        @conversation.save
        @current_user.conversations << @conversation
        Person.find(params[:message][:receiver_id]).conversations << @conversation
      end  
      @conversation.messages << @message
      flash[:notice] = :reply_sent  
      redirect_to listing_path(listing)
    else
      flash[:error] = :reply_could_not_be_sent
      render :template => "listings/reply"
    end    
  end

end
