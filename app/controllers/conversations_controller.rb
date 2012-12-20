class ConversationsController < ApplicationController

  layout "inbox", :only => [ :index, :received, :sent, :show ]
  
  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_send_a_message"
  end
  
  before_filter :except => [ :new, :create ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_view_your_inbox"
  end
  
  before_filter :only => [ :index, :received, :sent, :notifications ] do |controller|
    controller.ensure_authorized "you_are_not_authorized_to_view_this_content"
  end
  
  before_filter :ensure_authorized_to_view_message, :only => [ :show, :accept, :reject ]
  before_filter :save_current_inbox_path, :only => [ :received, :sent, :show ]
  before_filter :check_conversation_type, :only => [ :new, :create ]
  before_filter :ensure_listing_is_open, :only => [ :new, :create ]
  before_filter :ensure_listing_author_is_not_current_user, :only => [ :new, :create ]
  before_filter :ensure_authorized_to_reply, :only => [ :new, :create ]
  
  skip_filter :dashboard_only
  
  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:accept, :reject]
  
  def index
    redirect_to received_person_messages_path(:person_id => @current_user.id)
  end
  
  def received
    params[:page] = 1 unless request.xhr?
    @conversations = @current_user.messages_that_are("received").paginate(:per_page => 15, :page => params[:page])
    request.xhr? ? (render :partial => "additional_messages") : (render :action => :index)
  end
  
  def sent
    params[:page] = 1 unless request.xhr?
    @conversations = @current_user.messages_that_are("sent").paginate(:per_page => 15, :page => params[:page])
    request.xhr? ? (render :partial => "additional_messages") : (render :action => :index)
  end
  
  def notifications
    @notifications = @current_user.notifications.paginate(:per_page => 20, :page => params[:page])
    @unread_notifications = @current_user.notifications.unread.all
    @current_user.mark_all_notifications_as_read
    render :partial => "additional_notifications" if request.xhr?
  end
  
  def show
    @current_user.read(@conversation) unless @conversation.read_by?(@current_user)
    @other_party = @conversation.other_party(@current_user)
  end

  def new
    @conversation = Conversation.new
    @conversation.messages.build
    @conversation.participants.build
    @target_person ||= @listing.author
    render :action => :new, :layout => "application"
  end
  
  def create
    @conversation = Conversation.new(params[:conversation])
    if @conversation.save
      flash[:notice] = "message_sent"
      Delayed::Job.enqueue(MessageSentJob.new(@conversation.id, @conversation.messages.last.id, request.host))
      if params[:profile_message]
        redirect_to @target_person
      else
        redirect_to session[:return_to_content] || root
      end
    else
      render :action => :new
    end  
  end
  
  def accept
    change_status("accepted")
  end
  
  def reject
    change_status("rejected")
  end
  
  private
  
  # Saves current path so that the user can be
  # redirected back to that path when needed.
  def save_current_inbox_path
    session[:return_to_inbox_content] = request.fullpath
  end
  
  def change_status(status)
    @conversation.change_status(status, @current_user, @current_community, request.host)
    flash.now[:notice] = "#{@conversation.discussion_type}_#{status}"
    respond_to do |format|
      format.html { render :action => :show }
      format.js { render :layout => false }
    end
  end
  
  def ensure_authorized_to_view_message
    @conversation = Conversation.find(params[:id])
    unless @conversation.participants.include?(@current_user)
      flash[:error] = "you_are_not_authorized_to_view_this_content"
      redirect_to root and return
    end
  end
  
  # Check if type is free message or listing-related conversation.
  # If former, find the target person of the message.
  # If message is targeted to a commenter of a listing,
  # save the listing info.
  def check_conversation_type
    if params[:profile_message] || params[:comment_message]
      if params[:conversation]
        @target_person = Person.find(params[:target_person_id])
      else
        @target_person = Person.find(params[:person_id])
      end
    end
    @listing = Listing.find(params[:listing_id]) if params[:comment_message]
  end
  
  def ensure_listing_is_open
    unless @target_person
      @listing = params[:conversation] ? Listing.find(params[:conversation][:listing_id]) : Listing.find(params[:id])
      if @listing.closed?
        flash[:error] = "you_cannot_reply_to_a_closed_#{@listing.listing_type}"
        redirect_to (session[:return_to_content] || root)
      end
    end
  end
  
  def ensure_listing_author_is_not_current_user
    if (@target_person && current_user?(@target_person)) || (!params[:comment_message] && @listing && current_user?(@listing.author))
      flash[:error] = "you_cannot_send_message_to_yourself"
      redirect_to (session[:return_to_content] || root)
    end
  end
  
  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_reply
    if @listing && !@listing.visible_to?(@current_user, @current_community)
      flash[:error] = "you_are_not_authorized_to_view_this_content"
      redirect_to root and return
    end  
  end

end
