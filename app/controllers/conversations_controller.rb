class ConversationsController < ApplicationController

  def index
    save_navi_state(['own','inbox','',''])
    @conversations = @current_user.conversations.sort{ |b,a| a.updated_at <=> b.updated_at }
  end  

  def show
    @conversation = Conversation.find(params[:id])
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

end
