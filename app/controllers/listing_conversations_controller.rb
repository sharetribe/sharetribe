class ListingConversationsController < ApplicationController

  before_filter do |controller|
   controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter :fetch_listing_from_params
  before_filter :ensure_listing_is_open
  before_filter :ensure_listing_author_is_not_current_user
  before_filter :ensure_authorized_to_reply

  skip_filter :dashboard_only

  def new
    use_contact_view = @listing.status_after_reply == "free"
    @listing_conversation = new_conversation

    if use_contact_view
      render :contact, locals: {contact: false}
    else
      render :new_with_payment
    end
  end

  def preauthorize
    booking = if @listing.transaction_type.price_per.present?
      Booking.new({
        start_on: params[:start_on],
        end_on: params[:end_on]
      })
    end

    if booking.present? && !booking.valid?
      flash[:error] = booking.errors.full_messages
      redirect_to @listing and return
    end

    @braintree_client_side_encryption_key = @current_community.payment_gateway.braintree_client_side_encryption_key

    @listing_conversation = new_conversation()
    @listing_conversation.booking = booking
    @payment = @listing_conversation.initialize_payment

    @payment.sum = @listing_conversation.calculate_total
  end

  def preauthorized
    conversation_params = params[:listing_conversation]

    if @current_community.transaction_agreement_in_use? && conversation_params[:contract_agreed] != "1"
      flash[:error] = "Agreement checkbox has to be selected"
      return redirect_to action: :preauthorize
    end

    @listing_conversation = new_conversation(conversation_params)
    @payment = @listing_conversation.initialize_payment

    @payment.sum = @listing_conversation.calculate_total

    pay(@current_user, @listing_conversation, @payment)
  end

  def pay(payer, listing_conversation, payment)
    result = BraintreeSaleService.new(payment, params[:braintree_payment]).pay(false)
    recipient = payment.recipient

    if result.success?
      @listing_conversation.save!
      listing_conversation.status = "preauthorized"
      redirect_to person_message_path(:id => listing_conversation.id)
    else
      flash[:error] = result.message
      redirect_to action: :preauthorize
    end
  end

  def contact
    @listing_conversation = new_conversation
    render :contact, locals: {contact: true}
  end

  def create
    conversation = save_conversation(params[:listing_conversation])

    if conversation
      conversation.status = @listing.status_after_reply

      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(@listing_conversation.messages.last.id, @current_community.id))
      redirect_to session[:return_to_content] || root
    else
      flash[:error] = "Sending the message failed. Please try again."
      redirect_to root
    end
  end

  def create_contact
    conversation = save_conversation(params[:listing_conversation])

    if conversation
      conversation.status = "free"

      flash[:notice] = t("layouts.notifications.message_sent")
      Delayed::Job.enqueue(MessageSentJob.new(@listing_conversation.messages.last.id, @current_community.id))
      redirect_to session[:return_to_content] || root
    else
      flash[:error] = "Sending the message failed. Please try again."
      redirect_to root
    end
  end

  private

  def save_conversation(params)
    @listing_conversation = new_conversation(params)
    if @listing_conversation.save
      @listing_conversation
    else
      nil
    end
  end

  def ensure_listing_author_is_not_current_user
    if @listing.author == @current_user
      flash[:error] = t("layouts.notifications.you_cannot_send_message_to_yourself")
      redirect_to (session[:return_to_content] || root)
    end
  end

  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_reply
    unless @listing.visible_to?(@current_user, @current_community)
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      redirect_to root and return
    end
  end

  def ensure_listing_is_open
    if @listing.closed?
      flash[:error] = t("layouts.notifications.you_cannot_reply_to_a_closed_#{@listing.direction}")
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing_from_params
    @listing = Listing.find(params[:listing_id] || params[:id])
  end

  def new_conversation(conversation_params = {})
    conversation = ListingConversation.new(conversation_params.merge(community: @current_community, listing: @listing))
    conversation.build_starter_participation(@current_user)
    conversation.build_participation(@listing.author)
    conversation
  end
end