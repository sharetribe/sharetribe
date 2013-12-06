class BraintreePaymentsController < ApplicationController
  
  # TODO Add filter: Only if Braintree in use

  # TODO These should be shared with PaymentsController
  before_filter :payment_can_be_conducted
  
  before_filter :only => [ :new ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end
  
  skip_filter :dashboard_only

  # This expects that each conversation already has a (pending) payment at this point
  def edit
    @conversation = Conversation.find(params[:message_id])
    @braintree_payment = @conversation.payment
    payment_gateway = @current_community.community_payment_gateways.first
    @braintree_client_side_encryption_key = payment_gateway.braintree_client_side_encryption_key
  end

  def update
    @conversation = Conversation.find(params[:message_id])
    @braintree_payment = @conversation.payment
    payer = @current_user
    recipient = @braintree_payment.recipient

    amount = 100 # FIXME
    service_fee = 10 # FIXME

    log_info("Sending sale transaction from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}")

    payment_params = params[:braintree_payment]

    result = BraintreeService.transaction_sale(
      recipient, 
      payment_params[:credit_card_number], 
      payment_params[:credit_card_expiration_date], 
      amount, 
      service_fee, 
      @current_community
    )

    if result.success?
      log_info("Successful sale transaction from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}")
      transaction = result.transaction
    else
      log_error("Unsuccessful sale transaction from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}: #{result.message}")
    end

    # Where to?
  end

  private
  
  def payment_can_be_conducted
    @conversation = Conversation.find(params[:message_id])
    redirect_to person_message_path(@current_user, @conversation) unless @conversation.requires_payment?(@current_community)
  end

  def log_info(msg)
    logger.info "[Braintree] #{msg}"
  end

  def log_error(msg)
    logger.error "[Braintree] #{msg}"
  end
end
