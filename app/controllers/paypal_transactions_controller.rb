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

    token = PaypalService::Store::Token.get(@current_community.id, params[:token])

    # Create a new payment using the token form param
    response = transaction_service.preauthorize(
      token[:transaction_id],
      TransactionService::DataTypes::Transaction.create_paypal_preauthorize_fields(
        token: params[:token]))

    if !response[:success]
      transaction_response = response[:data][:transaction]
      gateway_response = response[:data][:gateway_fields]

      if gateway_response[:paypal_error_code] == "10486"
        redirect_to gateway_response[:redirect_url]
      else
        flash[:error] = t("paypal.generic_error")
        redirect_to person_listing_path(person_id: @current_user.id, :id => transaction_response[:listing_id])
      end
    else
      redirect_to person_transaction_path(:person_id => @current_user.id, :id => response[:data][:transacton][:id])
    end
  end

  def paypal_checkout_order_cancel
    pp_result = paypal_payments_service.request_cancel(@current_community.id, params[:token])
    if(!pp_result[:success])
      flash[:error] = t("error_messages.paypal.cancel_error")
      return redirect_to root
    end

    flash[:notice] = t("paypal.cancel_succesful")
    return redirect_to person_listing_path(person_id: @current_user.id, :id => params[:listing_id])
  end

  private

  def transaction_service
    TransactionService::Transaction
  end

  def paypal_payments_service
    PaypalService::API::Api.payments
  end

end
