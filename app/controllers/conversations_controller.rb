class ConversationsController < ApplicationController

  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_send_a_message"
  end
  
  def received
    @conversations = @current_user.messages_that_are("received")
    logger.info "Conversations: " + @conversations.inspect
    render :action => :index
  end
  
  def sent
    @conversations = @current_user.messages_that_are("sent")
    logger.info "Conversations: " + @conversations.inspect
    render :action => :index
  end

  def new
    @listing = Listing.find(params[:id])
    logger.info "Listing: #{@listing}"
    redirect_to session[:return_to_content] and return if is_current_user?(@listing.author)
    @conversation = Conversation.new
    @conversation.messages.build
    @conversation.participants.build
  end
  
  def create
    @conversation = Conversation.new(params[:conversation])
    if @conversation.save
      flash[:notice] = "#{@conversation.listing.category}_#{@conversation.listing.listing_type}_message_sent"
      redirect_to session[:return_to_content]
    else
      @listing = Listing.find(params[:conversation][:listing_id])
      render :action => :new
    end  
  end

end
