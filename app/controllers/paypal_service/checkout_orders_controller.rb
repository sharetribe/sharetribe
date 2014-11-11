class PaypalService::CheckoutOrdersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_filter :check_email_confirmation, :dashboard_only

  before_filter do
    unless @current_community.paypal_enabled?
      render :nothing => true, :status => 400 and return
    end
  end


  def success
    return redirect_to error_not_found_path if params[:token].blank?

    token = paypal_payments_service.get_request_token(@current_community.id, params[:token])
    return redirect_to error_not_found_path if !token[:success]

    transaction = transaction_service.query(token[:data][:transaction_id])

    proc_status = paypal_payments_service.create(
      @current_community.id,
      token[:data][:token],
      async: true)


    if !proc_status[:success]
      flash[:error] = t("error_messages.paypal.generic_error")
      return redirect_to root
    end

    render "paypal_service/success", layout: false, locals: {
      op_status_url: transaction_op_status_path(proc_status[:data][:process_token]),
      redirect_url: success_processed_paypal_service_checkout_orders_path(
        process_token: proc_status[:data][:process_token],
        listing_id: transaction[:listing_id])
    }

  end

  def success_processed
    process_token = params[:process_token]
    listing_id = params[:listing_id]

    proc_status = paypal_process_api.get_status(process_token)
    unless (proc_status[:success] && proc_status[:data][:completed])
      return redirect_to error_not_found_path
    end

    response_data = proc_status[:data][:result][:data] || {}

    if proc_status[:data][:result][:success]
      redirect_to person_transaction_path(person_id: @current_user.id, id: response_data[:transaction_id])
    else
      if response_data[:paypal_error_code] == "10486"
        redirect_to response_data[:redirect_url]
      else
        flash[:error] = t("error_messages.paypal.generic_error")
        redirect_to person_listing_path(person_id: @current_user.id, id: listing_id)
      end
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

  def paypal_process_api
    PaypalService::API::Api.process
  end

end
