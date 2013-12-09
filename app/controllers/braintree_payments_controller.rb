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

    amount = @braintree_payment.sum_without_commission
    service_fee = @braintree_payment.total_commission

    log_info("Sending sale transaction from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}")

    payment_params = params[:braintree_payment] || {}

    result = with_expection_logging do 
      BraintreeService.transaction_sale(
        recipient,
        payment_params,
        amount,
        service_fee,
        @current_community
      )
    end

    if result.success?
      transaction_id = result.transaction.id
      log_info("Successful sale transaction #{transaction_id} from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}")
      @braintree_payment.paid!
      @braintree_payment.braintree_transaction_id = transaction_id
      @braintree_payment.save
      redirect_to person_message_path(:id => params[:message_id])
    else
      log_error("Unsuccessful sale transaction from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}: #{result.message}")
      flash[:error] = result.message
      redirect_to :edit_person_message_braintree_payment
    end
  end

  private
  
  def payment_can_be_conducted
    @conversation = Conversation.find(params[:message_id])
    redirect_to person_message_path(@current_user, @conversation) unless @conversation.requires_payment?(@current_community)
  end

  def with_expection_logging(&block)
    begin
      block.call
    rescue Exception => e
      log_error("Expection #{e}")
      raise e
    end
  end

  def log_info(msg)
    logger.info "[Braintree] #{msg}"
  end

  def log_error(msg)
    logger.error "[Braintree] #{msg}"
  end
end
