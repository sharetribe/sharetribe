class PaypalService::CheckoutOrdersController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action do
    unless PaypalHelper.community_ready_for_payments?(@current_community.id)
      render :body => nil, :status => 400
    end
  end


  def success
    return redirect_to error_not_found_path if params[:token].blank?

    token = paypal_payments_service.get_request_token(@current_community.id, params[:token])
    return redirect_to error_not_found_path if !token[:success]

    transaction = Transaction.find(token[:data][:transaction_id])

    proc_status = paypal_payments_service.create(
      @current_community.id,
      token[:data][:token],
      force_sync: false)


    if !proc_status[:success]
      flash[:error] = t("error_messages.paypal.generic_error")
      return redirect_to search_path
    end

    render "paypal_service/success", layout: false, locals: {
             op_status_url: paypal_op_status_path(proc_status[:data][:process_token]),
             redirect_url: success_processed_paypal_service_checkout_orders_path(
               process_token: proc_status[:data][:process_token],
               listing_id: transaction[:listing_id])
           }
  end

  def success_processed
    process_token = params[:process_token]
    listing_id = params[:listing_id]

    proc_status = PaypalService::API::Api.process.get_status(process_token)
    unless (proc_status[:success] && proc_status[:data][:completed])
      return redirect_to error_not_found_path
    end

    handle_proc_result(proc_status[:data][:result], listing_id)
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

  def paypal_op_status
    resp = Maybe(params[:process_token])
      .map { |ptok| PaypalService::API::Api.process.get_status(ptok) }
      .select(&:success)
      .data
      .or_else(nil)

    if resp
      render :json => resp
    else
      head :not_found
    end
  end

  private

  def handle_proc_result(response, listing_id)
    response_data = response[:data] || {}

    if response[:success]
      redirect_to transaction_created_path(transaction_id: response_data[:transaction_id])
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
      elsif response_data[:paypal_error_code] == "10417"
        # https://www.paypal.com/us/selfhelp/article/What-is-API-error-code-10417-FAQ3308

        flash[:error] = t("error_messages.paypal.transaction_cannot_complete")
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


  def paypal_payments_service
    PaypalService::API::Api.payments
  end
end
