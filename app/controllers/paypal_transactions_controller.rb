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

    pp_response = paypal_payments_service.create(@current_community.id, params[:token])

    if !pp_response[:success]
      redirect_to root
    end

    # do_authorization
    # do_authorization_req = DataTypeMerchant.create_do_authorization({
    #     receiver_username: paypal_receiver[:email],
    #     order_id: do_express_checkout_payment_res[:order_id],
    #     authorization_total: express_checkout_details_res[:order_total]
    #   })
    # do_authorization_res = paypal_merchant.do_request(do_authorization_req)

    # if !do_authorization_res[:success]
    #   return #TODO LOG THIS and RETRY?
    # end

    # PaypalService::PaypalPayment::Command.update(
    #   express_checkout_details_res.merge(do_express_checkout_payment_res).merge(do_authorization_res)
    # )

    transaction_id = pp_response[:data][:transaction_id]
    MarketplaceService::Transaction::Command.transition_to(transaction_id, "preauthorized")

    return redirect_to person_transaction_path(:person_id => @current_user.id, :id => transaction_id)
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
