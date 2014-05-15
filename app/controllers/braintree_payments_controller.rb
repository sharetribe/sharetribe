class BraintreePaymentsController < ApplicationController

  before_filter :fetch_conversation
  before_filter :ensure_not_paid_already
  before_filter :payment_can_be_conducted

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  before_filter :ensure_recipient_does_not_have_account_for_another_community

  skip_filter :dashboard_only

  # This expects that each conversation already has a (pending) payment at this point
  def edit
    @conversation = Conversation.find(params[:message_id])
    @braintree_payment = @conversation.payment
    community_payment_gateway = @current_community.payment_gateway
    @braintree_client_side_encryption_key = community_payment_gateway.braintree_client_side_encryption_key
  end

  def update
    payer = @current_user
    recipient = @braintree_payment.recipient
    listing = @conversation.listing

    price = @braintree_payment.sum_cents

    amount = price.to_f / 100  # Braintree want's whole dollars
    service_fee = @braintree_payment.total_commission.cents.to_f / 100

    BTLog.warn("Sending sale transaction from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}")

    payment_params = params[:braintree_payment] || {}

    result = with_expection_logging do
      BraintreeApi.transaction_sale(
        recipient,
        payment_params,
        amount,
        service_fee,
        @current_community.payment_gateway.hold_in_escrow,
        @current_community
      )
    end

    if result.success?
      transaction_id = result.transaction.id
      BTLog.warn("Successful sale transaction #{transaction_id} from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}")
      @braintree_payment.paid!
      @braintree_payment.braintree_transaction_id = transaction_id
      @braintree_payment.save
      redirect_to person_message_path(:id => params[:message_id])
    else
      BTLog.error("Unsuccessful sale transaction from #{payer.id} to #{recipient.id}. Amount: #{amount}, fee: #{service_fee}: #{result.message}")
      flash[:error] = result.message
      redirect_to :edit_person_message_braintree_payment
    end
  end

  private

  # Before filter
  #
  # Support for multiple Braintree account in multipe communities
  # is not implemented. Show error.
  def ensure_recipient_does_not_have_account_for_another_community
    @braintree_account = BraintreeAccount.find_by_person_id(@braintree_payment.recipient_id)

    if @braintree_account
      # Braintree account exists
      if @braintree_account.community_id.present? && @braintree_account.community_id != @current_community.id
        # ...but is associated to different community
        account_community = Community.find(@braintree_account.community_id)
        flash[:error] = "Unfortunately, we can not proceed with the payment. Please contact administrators."

        error_msg = "User #{@current_user.id} tries to pay for user #{@braintree_payment.recipient_id} which has Braintree account for another community #{account_community.name(I18n.locale)}"
        BTLog.error(error_msg)
        ApplicationHelper.send_error_notification(error_msg, "BraintreePaymentAccountError")
        redirect_to person_message_path
      end
    end
  end

  # Before filter
  def fetch_conversation
    @conversation = Conversation.find(params[:message_id])
    @braintree_payment = @conversation.payment
  end

  # Before filter
  def ensure_not_paid_already
    if @conversation.payment.status != "pending"
      flash[:error] = "Could not find pending payment. It might be the payment is paid already."
      redirect_to single_conversation_path(:conversation_type => :received, :id => @conversation.id) and return
    end
  end

  def payment_can_be_conducted
    redirect_to person_message_path(@current_user, @conversation) unless @conversation.requires_payment?(@current_community)
  end

  def with_expection_logging(&block)
    begin
      block.call
    rescue Exception => e
      BTLog.error("Expection #{e}")
      raise e
    end
  end
end
