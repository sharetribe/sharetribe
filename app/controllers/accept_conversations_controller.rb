class AcceptConversationsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_filter :fetch_conversation
  before_filter :fetch_listing

  before_filter :ensure_is_author

  skip_filter :dashboard_only

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token

  def accept
    prepare_accept_or_reject_form
    @action = "accept"
    payment_settings_path =
      if @current_community.payment_gateway.gateway_type == :braintree
        show_braintree_settings_payment_path(@current_user)
      elsif @current_community.payment_gateway.gateway_type == :checkout
        person_checkout_account_path(@current_user)
      end

    render(locals: {payment_settings_path: payment_settings_path})
  end

  def reject
    prepare_accept_or_reject_form
    @action = "reject"
    render :accept
  end

  # Handles accept and reject forms
  def acceptance
    # Update first everything else than the status, so that the payment is in correct
    # state before the status change callback is called
    if @listing_conversation.update_attributes(params[:listing_conversation].except(:status))
      @listing_conversation.status = params[:listing_conversation][:status]

      close_listing = params[:close_listing]
      listing.update_attribute(:open, false) if close_listing && close_listing.eql?("true")

      flash[:notice] = t("layouts.notifications.#{@listing_conversation.discussion_type}_#{@listing_conversation.status}")
      redirect_to person_message_path(:person_id => @current_user.id, :id => @listing_conversation.id)
    else
      flash[:error] = t("layouts.notifications.something_went_wrong")
      redirect_to person_message_path(@current_user, @listing_conversation)
    end
  end

  private

  def prepare_accept_or_reject_form
    @payment = @current_community.payment_gateway.new_payment
    @payment.community = @current_community
    @payment.default_sum(@listing_conversation.listing, Maybe(@current_community).vat.or_else(0))

    @payout_registration_missing = PaymentRegistrationGuard.new(@current_community, @current_user, @listing).requires_registration_before_accepting?
  end

  def ensure_is_author
    unless @listing.author == @current_user
      flash[:error] = "Only listing author can perform the requested action"
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing
    @listing = @listing_conversation.listing
  end

  def fetch_conversation
    @listing_conversation = ListingConversation.find(params[:id])
  end
end
