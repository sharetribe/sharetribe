class PaypalTransactionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_filter :check_email_confirmation, :dashboard_only

  before_filter do
    unless @current_community.paypal_enabled?
      render :nothing => true, :status => 400 and return
    end
  end


  def paypal_checkout_order_success
    if params[:token].blank?
      flash[:error] = t("error_messages.paypal.generic_error")
      # TODO Log?
      return redirect_to root
    end

    # Create a new payment using the token form param
    pp_response = paypal_payments_service.create(@current_community.id, params[:token])
    redirect_to root and return if !pp_response[:success]
    payment = pp_response[:data]

    # Authorize the payment
    auth_response = paypal_payments_service.authorize(
      @current_community.id,
      payment[:transaction_id],
      PaypalService::API::DataTypes.create_authorization_info({ authorization_total: payment[:order_total] }))
    redirect_to root and return if !auth_response[:success]

    MarketplaceService::Transaction::Command.transition_to(payment[:transaction_id], "preauthorized")

    return redirect_to person_transaction_path(:person_id => @current_user.id, :id => payment[:transaction_id])
  end

  def paypal_checkout_order_cancel
    # TODO Implementation missing
    binding.pry
  end

  private

  def paypal_payments_service
    PaypalService::API::Payments.new
  end

end
