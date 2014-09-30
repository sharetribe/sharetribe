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
    @conversation = Transaction.find(params[:message_id])
    @braintree_payment = @conversation.payment
    community_payment_gateway = @current_community.payment_gateway
    @braintree_client_side_encryption_key = community_payment_gateway.braintree_client_side_encryption_key
    render locals: {braintree_form: Form::Braintree.new}
  end

  def update
    payment = @braintree_payment
    braintree_form = Form::Braintree.new(params[:braintree_payment])
    result = BraintreeSaleService.new(payment, braintree_form.to_hash).pay(true)

    recipient = payment.recipient
    if result.success?
      MarketplaceService::Transaction::Command.transition_to(@conversation.id, "paid")
      redirect_to person_transaction_path(:id => params[:message_id])
    else
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
        redirect_to person_transaction_path(@current_user, @conversation)
      end
    end
  end

  # Before filter
  def fetch_conversation
    @conversation = Transaction.find(params[:message_id])
    @braintree_payment = @conversation.payment
  end

  # Before filter
  def ensure_not_paid_already
    if @conversation.payment.status != "pending"
      flash[:error] = "Could not find pending payment. It might be the payment is paid already."
      redirect_to person_transaction_path(@current_user, @conversation) and return
    end
  end

  def payment_can_be_conducted
    redirect_to person_transaction_path(@current_user, @conversation) unless @conversation.requires_payment?(@current_community)
  end
end
