class PaypalService::CheckoutOrdersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_filter :check_email_confirmation, :dashboard_only

  before_filter do
    unless @current_community.paypal_enabled?
      render :nothing => true, :status => 400 and return
    end
  end


  def success
    if params[:token].blank?
      flash[:error] = t("error_messages.paypal.generic_error")
      # TODO Log?
      return redirect_to root
    end

    pp_response = paypal_payments_service.create(@current_community.id, params[:token])

    if !pp_response[:success]
      response_data = pp_response[:data] || {}

      if response_data[:paypal_error_code] == "10486"
        redirect_to response_data[:redirect_url]
      else
        flash[:error] = t("paypal.generic_error")
        transaction = transaction_service.query(response_data[:transaction_id])
        redirect_to person_listing_path(person_id: @current_user.id, id: transaction[:listing_id])
      end
    else
      redirect_to person_transaction_path(person_id: @current_user.id, id: pp_response[:data][:transaction_id])
    end
  end

  def cancel
    pp_result = paypal_payments_service.request_cancel(@current_community.id, params[:token])
    if(!pp_result[:success])
      flash[:error] = t("error_messages.paypal.cancel_error")
      return redirect_to root
    end

    flash[:notice] = t("paypal.cancel_succesful")
    return redirect_to person_listing_path(person_id: @current_user.id, id: params[:listing_id])
  end

  private

  def transaction_service
    TransactionService::Transaction
  end

  def paypal_payments_service
    PaypalService::API::Api.payments
  end

end
