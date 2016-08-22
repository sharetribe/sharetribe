class AcceptConversationsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_filter :fetch_conversation
  before_filter :fetch_listing

  before_filter :ensure_is_author

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token

  MessageForm = Form::Message

  def reject
    prepare_accept_or_reject_form
    @action = "reject"
    path_to_payment_settings = paypal_account_settings_payment_path(@current_user)
    render(:accept, locals: { path_to_payment_settings: path_to_payment_settings, message_form: MessageForm.new })
  end

  # Handles accept and reject forms
  def acceptance
    # Update first everything else than the status, so that the payment is in correct
    # state before the status change callback is called
    if @listing_conversation.update_attributes(params[:listing_conversation].except(:status))
      message = MessageForm.new(params[:message].merge({ conversation_id: @listing_conversation.id }))
      if(message.valid?)
        @listing_conversation.conversation.messages.create({content: message.content}.merge(sender_id: @current_user.id))
      end

      MarketplaceService::Transaction::Command.transition_to(@listing_conversation.id, params[:listing_conversation][:status])
      MarketplaceService::Transaction::Command.mark_as_unseen_by_other(@listing_conversation.id, @current_user.id)

      flash[:notice] = t("layouts.notifications.request_#{params[:listing_conversation][:status]}")
      redirect_to person_transaction_path(:person_id => @current_user.id, :id => @listing_conversation.id)
    else
      flash[:error] = t("layouts.notifications.something_went_wrong")
      redirect_to person_transaction_path(@current_user, @listing_conversation)
    end
  end

  private

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
    @listing_conversation = Transaction.find(params[:id])
  end
end
