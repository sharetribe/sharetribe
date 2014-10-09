class PaypalTransactionsController < ApplicationController
  include PaypalService::PermissionsInjector
  include PaypalService::MerchantInjector

  skip_before_filter :verify_authenticity_token
  skip_filter :check_email_confirmation, :dashboard_only

  before_filter do
    unless @current_community.paypal_enabled?
      render :nothing => true, :status => 400 and return
    end
  end

  DataTypePermissions = PaypalService::DataTypes::Permissions
  DataTypeMerchant = PaypalService::DataTypes::Merchant
  PaypalAccountCommand = PaypalService::PaypalAccount::Command
  PaypalAccountQuery = PaypalService::PaypalAccount::Query
  TokenQuery = PaypalService::Token::Query


  def paypal_checkout_order_success
    if params[:token].blank?
      flash[:error] = t("error_messages.paypal.generic_error")
      # TODO Log?
      return redirect_to root
    end

    paypal_token = TokenQuery.for_token(params[:token])
    transaction_id = paypal_token[:transaction_id]

    if transaction_id.blank?
      flash[:error] = t("error_messages.paypal.generic_error")
      # TODO Log?
      return redirect_to root
    end

    listing_author_id = Transaction.find(transaction_id).author.id

    paypal_receiver = PaypalAccountQuery.personal_account(listing_author_id, @current_community.id)

    # get_express_checkout_details
    express_checkout_details_req = DataTypeMerchant.create_get_express_checkout_details({
        receiver_username: paypal_receiver[:email],
        token: params[:token]
      })
    express_checkout_details_res = paypal_merchant.do_request(express_checkout_details_req)

    if !express_checkout_details_res[:success]
      return #TODO LOG THIS and RETRY?
    end

    # do_express_checkout_payment
    do_express_checkout_payment_req = DataTypeMerchant.create_do_express_checkout_payment({
        receiver_username: paypal_receiver[:email],
        token: params[:token],
        payer_id: express_checkout_details_res[:payer_id],
        order_total: express_checkout_details_res[:order_total]
      })
    do_express_checkout_payment_res = paypal_merchant.do_request(do_express_checkout_payment_req)

    if !do_express_checkout_payment_res[:success]
      return #TODO LOG THIS and RETRY?
    end

    PaypalService::PaypalPayment::Command.create(
      transaction_id,
      express_checkout_details_res.merge(do_express_checkout_payment_res)
    )

    # do_authorization
    do_authorization_req = DataTypeMerchant.create_do_authorization({
        receiver_username: paypal_receiver[:email],
        order_id: do_express_checkout_payment_res[:order_id],
        authorization_total: express_checkout_details_res[:order_total]
      })
    do_authorization_res = paypal_merchant.do_request(do_authorization_req)

    if !do_authorization_res[:success]
      return #TODO LOG THIS and RETRY?
    end

    PaypalService::PaypalPayment::Command.update(
      express_checkout_details_res.merge(do_express_checkout_payment_res).merge(do_authorization_res)
    )

    # TODO: think this throug!
    MarketplaceService::Transaction::Command.transition_to(transaction_id, "preauthorized")
    return redirect_to person_transaction_path(:person_id => @current_user.id, :id => transaction_id)
  end

  def paypal_checkout_order_cancel
    binding.pry
  end

end
