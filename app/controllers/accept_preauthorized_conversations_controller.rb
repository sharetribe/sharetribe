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
    update_listing_status do
      flash[:notice] = t("layouts.notifications.#{@listing_conversation.discussion_type}_accepted")
    end
  end

  def rejected
    update_listing_status do
      flash[:notice] = t("layouts.notifications.#{@listing_conversation.discussion_type}_rejected")
    end
  end

  private

  # Update listing status and call success block. In the block you can e.g. set flash notices.
  def update_listing_status(&block)
    @listing_conversation.conversation.messages.build({
      content: params[:listing_conversation][:message_attributes][:content],
      sender_id: @current_user.id
    })

    if @listing_conversation.save!
      case params[:listing_conversation][:status]
      when "paid"
        response = TransactionService::Transaction.complete_preauthorization(@listing_conversation.id)
      when "rejected"
        MarketplaceService::Transaction::Command.transition_to(@listing_conversation.id, params[:listing_conversation][:status])
      end
      MarketplaceService::Transaction::Command.mark_as_unseen_by_other(@listing_conversation.id, @current_user.id)

      redirect_to person_transaction_path(:person_id => @current_user.id, :id => @listing_conversation.id)
      block.call
    else
      flash[:error] = t("layouts.notifications.something_went_wrong")
      redirect_to person_transaction_path(@current_user, @listing_conversation)
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
    transaction = MarketplaceService::Transaction::Query.transaction(@listing_conversation.id)
    paypal_payment = PaypalService::PaypalPayment::Query.for_transaction(transaction[:id])

    #TODO should this be in a service?
    service_fee = paypal_payment[:authorization_total] * (transaction[:commission_from_seller] / 100.0)

    render locals: {
      discussion_type: transaction[:discussion_type],
      sum: paypal_payment[:authorization_total],
      fee: service_fee,
      seller_gets: paypal_payment[:order_total] - service_fee,
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
