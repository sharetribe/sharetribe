class PaypalService::CheckoutOrdersController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter do
    unless PaypalHelper.community_ready_for_payments?(@current_community.id)
      render :nothing => true, :status => 400
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
      return redirect_to search_path
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
      elsif response_data[:paypal_error_code] == "13113"
        flash[:error] = t("error_messages.paypal.buyer_cannot_pay_error",
                          customer_service_link: view_context.link_to("https://www.paypal.com/contactus",
                                                                      "https://www.paypal.com/contactus",
                                                                      class: "flash-error-link"))
                        .html_safe
        redirect_to person_listing_path(person_id: @current_user.id, id: listing_id)

      elsif response_data[:paypal_error_code] == "10425"
        flash[:error] = t("error_messages.paypal.seller_express_checkout_disabled")
        redirect_to person_listing_path(person_id: @current_user.id, id: listing_id)
      elsif response_data[:error_code] == :"payment-review"
        flash[:warning] = t("error_messages.paypal.pending_review_error")
        redirect_to person_listing_path(person_id: @current_user.id, id: listing_id)
      else
        flash[:error] = t("error_messages.paypal.generic_error")
        warn("Unhandled PayPal error response. Showing generic error to user.", :paypal_unhandled_error, response_data)
        redirect_to person_listing_path(person_id: @current_user.id, id: listing_id)
      end
    end
  end

  def cancel
    pp_result = paypal_payments_service.request_cancel(@current_community.id, params[:token])
    if(!pp_result[:success])
      flash[:error] = t("error_messages.paypal.cancel_error")
      return redirect_to search_path
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
