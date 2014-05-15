class ConversationsController < ApplicationController

  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter :except => [ :new, :create ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  before_filter :only => [ :index, :received, :sent, :notifications ] do |controller|
    controller.ensure_authorized t("layouts.notifications.you_are_not_authorized_to_view_this_content")
  end

  before_filter :ensure_authorized_to_view_message, :only => [ :show, :accept, :reject, :confirm, :cancel, :acceptance, :confirmation ]
  before_filter :save_current_inbox_path, :only => [ :received, :sent, :show ]
  before_filter :check_conversation_type, :only => [ :new, :create ]
  before_filter :ensure_listing_is_open, :only => [ :new, :create ]
  before_filter :ensure_listing_author_is_not_current_user, :only => [ :new, :create ]
  before_filter :ensure_authorized_to_reply, :only => [ :new, :create ]
  before_filter :ensure_authorized_to_accept, :only => [ :accept, :reject, :acceptance ]
  before_filter :ensure_authorized_to_cancel, :only => [ :confirm, :cancel, :canfirmation ]

  skip_filter :dashboard_only

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:accept, :reject]

  def index
    @selected_left_navi_link = "messages"
    redirect_to received_person_messages_path(:person_id => @current_user.id)
  end

  def received
    @selected_left_navi_link = "messages"
    params[:page] = 1 unless request.xhr?
    @conversations = @current_user.conversations.order("last_message_at DESC").paginate(:per_page => 15, :page => params[:page])
    request.xhr? ? (render :partial => "additional_messages") : (render :action => :index)
  end

  def notifications
    @selected_left_navi_link = "notifications"
    @notifications = @current_user.notifications.paginate(:per_page => 20, :page => params[:page])
    @unread_notifications = @current_user.notifications.unread.all
    @current_user.mark_all_notifications_as_read
    render :partial => "additional_notifications" if request.xhr?
  end

  def show
    @selected_left_navi_link = "messages"
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
    params[:conversation][:status] ||= "pending"

    @conversation = Conversation.new(params[:conversation])
    if @conversation.save
      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(@conversation.messages.last.id, @current_community.id))
      if params[:profile_message]
        redirect_to @target_person
      else
        redirect_to session[:return_to_content] || root
      end
    else
      flash[:error] = "Sending the message failed. Please try again."
      redirect_to root
    end
  end

  def accept
    prepare_accept_or_reject_form
    @action = "accept"
  end

  def reject
    prepare_accept_or_reject_form
    @action = "reject"
    render :accept
  end

  # Handles accept and reject forms
  def acceptance
    status = params[:conversation][:status]

    # Update first everything else than the status, so that the payment is in correct
    # state before the status change callback is called
    if @conversation.update_attributes(params[:conversation].except(:status))
      @conversation.status = status

      close_listing = params[:close_listing]
      listing.update_attribute(:open, false) if close_listing && close_listing.eql?("true")

      flash[:notice] = t("layouts.notifications.#{@conversation.discussion_type}_#{@conversation.status}")
      redirect_to person_message_path(:person_id => @current_user.id, :id => @conversation.id)
    else
      flash[:error] = t("layouts.notifications.something_went_wrong")
      redirect_to person_message_path(@current_user, @conversation)
    end
  end

  def confirm
    @action = "confirm"
  end

  def cancel
    @action = "cancel"
    render :confirm
  end

  # Handles confirm and cancel forms
  def confirmation
    # Check if can be accepted or canceled
    cancel = (params[:conversation] && params[:conversation][:status] == "canceled")
    unless current_user?(@conversation.requester) && (cancel ? @conversation.can_be_canceled? : @conversation.can_be_confirmed?)
      redirect_to person_message_path(:person_id => @current_user.id, :message_id => @conversation.id) and return
    end
    if @conversation.update_attributes(params[:conversation])
      confirmation = ConfirmConversation.new(@conversation, @current_user, @current_community)
      confirmation.update_participation(params[:give_feedback])

      flash[:notice] = t("layouts.notifications.#{@conversation.listing.direction}_#{@conversation.status}")
      if params[:give_feedback] && params[:give_feedback].eql?("true")
        redirect_to new_person_message_feedback_path(:person_id => @current_user.id, :message_id => @conversation.id)
      else
        redirect_to person_message_path(:person_id => @current_user.id, :id => @conversation.id)
      end
    else
      flash.now[:error] = t("layouts.notifications.something_went_wrong")
      render :edit
    end
  end

  private

  # Saves current path so that the user can be
  # redirected back to that path when needed.
  def save_current_inbox_path
    session[:return_to_inbox_content] = request.fullpath
  end

  def ensure_authorized_to_view_message
    @conversation = Conversation.find(params[:id])
    unless @conversation.participants.include?(@current_user)
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
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
        flash[:error] = t("layouts.notifications.you_cannot_reply_to_a_closed_#{@listing.direction}")
        redirect_to (session[:return_to_content] || root)
      end
    end
  end

  def ensure_listing_author_is_not_current_user
    if (@target_person && current_user?(@target_person)) || (!params[:comment_message] && @listing && current_user?(@listing.author))
      flash[:error] = t("layouts.notifications.you_cannot_send_message_to_yourself")
      redirect_to (session[:return_to_content] || root)
    end
  end

  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_reply
    if @listing && !@listing.visible_to?(@current_user, @current_community)
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      redirect_to root and return
    end
  end

  def ensure_authorized_to_accept
    redirect_to person_message_path(:person_id => @current_user.id, :message_id => @conversation.id) and return unless @conversation.status.eql?("pending") && current_user?(@conversation.listing.author)
  end

  def ensure_authorized_to_cancel
    redirect_to person_message_path(:person_id => @current_user.id, :message_id => @conversation.id) and return unless @conversation.can_be_canceled? && current_user?(@conversation.requester)
  end

  def prepare_accept_or_reject_form
    if @current_community.payments_in_use?
      @payment = @current_community.payment_gateway.new_payment
      @payment.community = @current_community
      @payment.default_sum(@conversation.listing, Maybe(@current_community).vat.or_else(0))
    end

    if @current_community.requires_payout_registration? && @current_community.payment_possible_for?(@conversation.listing) && ! @current_user.can_receive_payments_at?(@current_community)
      @payout_registration_missing = true
    end

  end

end
