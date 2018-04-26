class AcceptPreauthorizedConversationsController < ApplicationController

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_action :fetch_transaction
  before_action :fetch_listing

  before_action :ensure_is_author

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_action :verify_authenticity_token

  def accept
    tx_id = params[:id]
    tx = @current_community.transactions.find(tx_id)

    if tx.current_state != 'preauthorized'
      redirect_to person_transaction_path(person_id: @current_user.id, id: tx_id)
      return
    end

    payment_type = tx.payment_gateway
    case payment_type
    when :paypal, :stripe
      render_payment_form("accept", payment_type)
    else
      raise ArgumentError.new("Unknown payment type: #{payment_type}")
    end
  end

  def reject
    tx_id = params[:id]
    tx = @current_community.transactions.find(tx_id)

    if tx.current_state != 'preauthorized'
      redirect_to person_transaction_path(person_id: @current_user.id, id: tx_id)
      return
    end

    payment_type = tx.payment_gateway
    case payment_type
    when :paypal, :stripe
      render_payment_form("reject", payment_type)
    else
      raise ArgumentError.new("Unknown payment type: #{payment_type}")
    end
  end

  def accepted_or_rejected
    tx_id = params[:id]
    message = params[:transaction][:message_attributes][:content]
    status = params[:transaction][:status].to_sym
    sender_id = @current_user.id

    tx = @current_community.transactions.find(tx_id)

    if tx.current_state != 'preauthorized'
      redirect_to person_transaction_path(person_id: @current_user.id, id: tx_id)
      return
    end

    res = accept_or_reject_tx(@current_community.id, tx_id, status, message, sender_id)

    if res[:success]
      flash[:notice] = success_msg(res[:flow])

      record_event(
        flash,
        status == :paid ? "PreauthorizedTransactionAccepted" : "PreauthorizedTransactionRejected",
        { listing_id: tx.listing_id,
          listing_uuid: UUIDUtils.parse_raw(tx.listing_uuid).to_s,
          transaction_id: tx.id })

      redirect_to person_transaction_path(person_id: sender_id, id: tx_id)
    else
      flash[:error] = error_msg(res[:flow], tx)
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

  def error_msg(flow, tx)
    payment_gateway = tx.payment_gateway
    if flow == :accept
      if payment_gateway == :paypal
        t("error_messages.paypal.accept_authorization_error")
      elsif payment_gateway == :stripe
        t("error_messages.stripe.accept_authorization_error")
      end
    elsif flow == :reject
      if payment_gateway == :paypal
        t("error_messages.paypal.reject_authorization_error")
      elsif payment_gateway == :stripe
        t("error_messages.stripe.reject_authorization_error")
      end
    end
  end

  def ensure_is_author
    unless @listing.author == @current_user
      flash[:error] = "Only listing author can perform the requested action"
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing
    @listing = @transaction.listing
  end

  def fetch_transaction
    @transaction = @current_community.transactions.find(params[:id])
  end

  def render_payment_form(preselected_action, payment_type)
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
    payment_details = TransactionService::Transaction.payment_details(@transaction)

    render "accept", locals: {
      listing: @listing,
      sum: @transaction.item_total + (payment_details[:payment_gateway_fee] || 0),
      fee: @transaction.commission,
      gateway_fee: payment_details[:payment_gateway_fee],
      seller_gets: payment_details[:total_price]- @transaction.commission,
      form: @transaction,
      form_action: acceptance_preauthorized_person_message_path(
        person_id: @current_user.id,
        id: @transaction.id
      ),
      preselected_action: preselected_action,
      paypal_fees_url: PaypalCountryHelper.fee_link(community_country_code),
      stripe_fees_url: "https://stripe.com/#{community_country_code.downcase}/pricing",
      paypal_commission: paypal_tx_settings[:commission_from_seller],
      stripe_commission: stripe_tx_settings[:commission_from_seller]
    }
  end

  def paypal_tx_settings
    Maybe(TransactionService::API::Api.settings.get(community_id: @current_community.id, payment_gateway: :paypal, payment_process: :preauthorize))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else({})
  end

  def stripe_tx_settings
    Maybe(TransactionService::API::Api.settings.get(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else({})
  end

end
