class AcceptPreauthorizedConversationsController < ApplicationController

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
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)

    case payment_type
    when :braintree
      render_braintree_form("accept")
    when :paypal
      render_paypal_form("accept")
    else
      raise "Unknown payment type: #{payment_type}"
    end
  end

  def reject
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)

    case payment_type
    when :braintree
      render_braintree_form("reject")
    when :paypal
      render_paypal_form("reject")
    else
      raise "Unknown payment type: #{payment_type}"
    end
  end

  def accepted
    message = params[:listing_conversation][:message_attributes][:content]
    sender_id = @current_user.id
    status = params[:listing_conversation][:status]

    with_updated_listing_status(@listing_conversation, status, sender_id) do |lc|
      with_optional_message(lc, message, sender_id) do |lc|
        MarketplaceService::Transaction::Command.mark_as_unseen_by_other(lc.id, sender_id)
        flash[:notice] = t("layouts.notifications.#{lc.discussion_type}_accepted")
        redirect_to person_transaction_path(person_id: sender_id, id: lc.id)
      end
    end

  end

  def rejected
    message = params[:listing_conversation][:message_attributes][:content]
    sender_id = @current_user.id
    status = params[:listing_conversation][:status]

    with_updated_listing_status(@listing_conversation, status, sender_id) do |lc|
      with_optional_message(lc, message, sender_id) do |lc|
        MarketplaceService::Transaction::Command.mark_as_unseen_by_other(lc.id, sender_id)
        flash[:notice] = t("layouts.notifications.#{lc.discussion_type}_rejected")
        redirect_to person_transaction_path(person_id: sender_id, id: lc.id)
      end
    end
  end

  private

  def with_optional_message(listing_conversation, message, sender_id, &block)
    if(message)
      listing_conversation.conversation.messages.create({
          content: message,
          sender_id: sender_id
        })
    end

    block.call(listing_conversation)
  end

  def with_updated_listing_status(listing_conversation, status, sender_id, &block)
    response =
      if(status == "paid")
        TransactionService::Transaction.complete_preauthorization(listing_conversation.id)
      elsif(status == "rejected")
        TransactionService::Transaction.reject(@current_community.id, listing_conversation.id)
      end

    if(response[:success])
      block.call(listing_conversation.reload)
    else
      if (status == "paid")
        flash[:error] = t("error_messages.paypal.accept_authorization_error")
      else
        flash[:error] = t("error_messages.paypal.reject_authorization_error")
      end

      redirect_to accept_preauthorized_person_message_path(person_id: sender_id , id: listing_conversation.id)
    end
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
    @listing_conversation = @current_community.transactions.find(params[:id])
  end

  def render_paypal_form(preselected_action)
    transaction_conversation = MarketplaceService::Transaction::Query.transaction(@listing_conversation.id)
    transaction = TransactionService::Transaction.query(@listing_conversation.id)

    render "accept", locals: {
      discussion_type: transaction_conversation[:discussion_type],
      sum: transaction[:checkout_total],
      fee: transaction[:commission_total],
      seller_gets: transaction[:checkout_total] - transaction[:commission_total],
      form: @listing_conversation, # TODO FIX ME, DONT USE MODEL
      form_action: acceptance_preauthorized_person_message_path(
        person_id: @current_user.id,
        id: @listing_conversation.id
      ),
      preselected_action: preselected_action
    }
  end

  def render_braintree_form(preselected_action)
    render locals: {
      discussion_type: @listing_conversation.discussion_type,
      sum: @listing_conversation.payment.total_sum,
      fee: @listing_conversation.payment.total_commission,
      seller_gets: @listing_conversation.payment.seller_gets,
      form: @listing_conversation,
      form_action: acceptance_preauthorized_person_message_path(
        person_id: @current_user.id,
        id: @listing_conversation.id
      ),
      preselected_action: preselected_action
    }
  end
end
