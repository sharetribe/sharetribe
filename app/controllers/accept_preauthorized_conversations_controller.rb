class AcceptPreauthorizedConversationsController < ApplicationController

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_action :fetch_conversation
  before_action :fetch_listing

  before_action :ensure_is_author

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_action :verify_authenticity_token

  def accept
    tx_id = params[:id]
    tx = TransactionService::API::Api.transactions.query(tx_id)

    if tx[:current_state] != :preauthorized
      redirect_to person_transaction_path(person_id: @current_user.id, id: tx_id)
      return
    end

    payment_type = tx[:payment_gateway]
    case payment_type
    when :paypal, :stripe
      render_payment_form("accept", payment_type)
    else
      raise ArgumentError.new("Unknown payment type: #{payment_type}")
    end
  end

  def reject
    tx_id = params[:id]
    tx = TransactionService::API::Api.transactions.query(tx_id)

    if tx[:current_state] != :preauthorized
      redirect_to person_transaction_path(person_id: @current_user.id, id: tx_id)
      return
    end

    payment_type = tx[:payment_gateway]
    case payment_type
    when :paypal, :stripe
      render_payment_form("reject", payment_type)
    else
      raise ArgumentError.new("Unknown payment type: #{payment_type}")
    end
  end

  def accepted_or_rejected
    tx_id = params[:id]
    message = params[:listing_conversation][:message_attributes][:content]
    status = params[:listing_conversation][:status].to_sym
    sender_id = @current_user.id

    tx = TransactionService::API::Api.transactions.query(tx_id)

    if tx[:current_state] != :preauthorized
      redirect_to person_transaction_path(person_id: @current_user.id, id: tx_id)
      return
    end

    res = accept_or_reject_tx(@current_community.id, tx_id, status, message, sender_id)

    if res[:success]
      flash[:notice] = success_msg(res[:flow])

      Analytics.record_event(
        flash,
        status == :paid ? "PreauthorizedTransactionAccepted" : "PreauthorizedTransactionRejected",
        { listing_id: tx[:listing_id],
          listing_uuid: tx[:listing_uuid].to_s,
          transaction_id: tx[:id] })

      redirect_to person_transaction_path(person_id: sender_id, id: tx_id)
    else
      flash[:error] = error_msg(res[:flow])
      redirect_to accept_preauthorized_person_message_path(person_id: sender_id , id: tx_id)
    end
  end

  private

  def accept_or_reject_tx(community_id, tx_id, status, message, sender_id)
    if (status == :paid)
      accept_tx(community_id, tx_id, message, sender_id)
    elsif (status == :rejected)
      reject_tx(community_id, tx_id, message, sender_id)
    else
      {flow: :unknown, success: false}
    end
  end

  def accept_tx(community_id, tx_id, message, sender_id)
    TransactionService::Transaction.complete_preauthorization(community_id: community_id,
                                                              transaction_id: tx_id,
                                                              message: message,
                                                              sender_id: sender_id)
      .maybe()
      .map { |_| {flow: :accept, success: true}}
      .or_else({flow: :accept, success: false})
  end

  def reject_tx(community_id, tx_id, message, sender_id)
    TransactionService::Transaction.reject(community_id: community_id,
                                           transaction_id: tx_id,
                                           message: message,
                                           sender_id: sender_id)
      .maybe()
      .map { |_| {flow: :reject, success: true}}
      .or_else({flow: :reject, success: false})
  end

  def success_msg(flow)
    if flow == :accept
      t("layouts.notifications.request_accepted")
    elsif flow == :reject
      t("layouts.notifications.request_rejected")
    end
  end

  def error_msg(flow)
    if flow == :accept
      t("error_messages.paypal.accept_authorization_error")
    elsif flow == :reject
      t("error_messages.paypal.reject_authorization_error")
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

  def render_payment_form(preselected_action, payment_type)
    transaction_conversation = MarketplaceService::Transaction::Query.transaction(@listing_conversation.id)
    result = TransactionService::Transaction.get(community_id: @current_community.id, transaction_id: @listing_conversation.id)
    transaction = result[:data]
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    render "accept", locals: {
      payment_gateway: payment_type,
      listing: @listing,
      listing_quantity: transaction[:listing_quantity],
      booking: transaction[:booking],
      orderer: @listing_conversation.starter,
      sum: transaction[:item_total] + (transaction[:payment_gateway_fee] || 0),
      fee: transaction[:commission_total],
      gateway_fee: transaction[:payment_gateway_fee],
      shipping_price: transaction[:shipping_price],
      shipping_address: transaction[:shipping_address],
      seller_gets: transaction[:checkout_total] - transaction[:commission_total],
      form: @listing_conversation, # TODO FIX ME, DONT USE MODEL
      form_action: acceptance_preauthorized_person_message_path(
        person_id: @current_user.id,
        id: @listing_conversation.id
      ),
      preselected_action: preselected_action,
      paypal_fees_url: PaypalCountryHelper.fee_link(community_country_code),
      stripe_fees_url: "https://stripe.com/#{community_country_code.downcase}/pricing"

    }
  end

end
