module PaypalService
  module MerchantActions

    MERCHANT_ACTIONS = {
      setup_billing_agreement: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            SetExpressCheckoutRequestDetails: {
              ReturnURL: req[:success],
              CancelURL: req[:cancel],
              ReqConfirmShipping: 0,
              NoShipping: 1,
              PaymentDetails: [{
                  OrderTotal: {value: "0.0"},
                  # NotifyURL: "https://paypal-sdk-samples.herokuapp.com/merchant/ipn_notify",
                  PaymentAction: "Authorization"
                }],
              BillingAgreementDetails: [{
                  BillingType: "ChannelInitiatedBilling",
                  BillingAgreementDescription: req[:description]
                }]
            }
          }
        },
        wrapper_method_name: :build_set_express_checkout,
        action_method_name: :set_express_checkout,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_setup_billing_agreement_response({
            token: res.token,
            redirect_url: api.express_checkout_url(res),
            username_to: api.config.subject || api.config.username
          })
        }
      ),

      create_billing_agreement: PaypalAction.def_action(
        input_transformer: -> (req) { { Token: req[:token] } },
        wrapper_method_name: :build_create_billing_agreement,
        action_method_name: :create_billing_agreement,
        output_transformer: -> (res, _) {
          DataTypes::Merchant.create_create_billing_agreement_response({
            billing_agreement_id: res.billing_agreement_id
          })
        }
      ),

      do_reference_transaction: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            DoReferenceTransactionRequestDetails: {
              ReferenceID: req[:billing_agreement_id],
              PaymentAction: "Sale",
              PaymentDetails: {
                OrderTotal: {
                  currencyID: req[:currency],
                  value: req[:order_total]
                }
              }
            }
          }
        },
        wrapper_method_name: :build_do_reference_transaction,
        action_method_name: :do_reference_transaction,
        output_transformer: -> (res, api) {
          details = res.do_reference_transaction_response_details
          DataTypes::Merchant.create_do_reference_transaction_response({
            billing_agreement_id: details.billing_agreement_id,
            transaction_id: details.payment_info.transaction_id,
            gross_amount: details.payment_info.gross_amount.value,
            gross_currency: details.payment_info.gross_amount.currency_id,
            fee_amount: details.payment_info.fee_amount.value,
            fee_currency: details.payment_info.fee_amount.currency_id,
            username_to: api.config.subject || api.config.username
          })
        }
      ),

      get_express_checkout_details: PaypalAction.def_action(
        input_transformer: -> (req) { { Token: req[:token] } },
        wrapper_method_name: :build_get_express_checkout_details,
        action_method_name: :get_express_checkout_details,
        output_transformer: -> (res, api) {
          details = res.get_express_checkout_details_response_details
          DataTypes::Merchant.create_get_express_checkout_details_response({
            token: details.token,
            checkout_status: details.checkout_status,
            billing_agreement_accepted: !!details.billing_agreement_accepted_status,
            payer: details.payer_info.payer,
            payer_id: details.payer_info.payer_id,
            order_total: details.payment_details[0].order_total.value,
            order_currency: details.payment_details[0].order_total.currency_id
          })
        }
      ),

      set_express_checkout_order: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            SetExpressCheckoutRequestDetails: {
              ReturnURL: req[:success],
              CancelURL: req[:cancel],
              ReqConfirmShipping: 0,
              NoShipping: 1,
              OrderDescription: req[:description],
              SolutionType: "Sole",
              LandingPage: "Billing",
              PaymentDetails: [{
                  OrderTotal: {
                    value: req[:order_total],
                    currencyID: req[:currency]
                  },
                  PaymentAction: "Order"
                }]
            }
          }
        },
        wrapper_method_name: :build_set_express_checkout,
        action_method_name: :set_express_checkout,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_set_express_checkout_order_response({
            token: res.token,
            redirect_url: api.express_checkout_url(res),
            receiver_username: api.config.subject || api.config.username
          })
        }
      ),

      do_express_checkout_payment: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            DoExpressCheckoutPaymentRequestDetails: {
              PaymentAction: "Order",
              Token: req[:token],
              PayerID: req[:payer_id],
              PaymentDetails: [{
                  OrderTotal: {
                    currencyID: req[:currency],
                    value: req[:order_total]
                  }
              }]
            }
          }
        },
        wrapper_method_name: :build_do_express_checkout_payment,
        action_method_name: :do_express_checkout_payment,
        output_transformer: -> (res, api) {
          payment_info = res.do_express_checkout_payment_response_details.payment_info[0]
          DataTypes::Merchant.create_do_express_checkout_payment_response(
            {
              payment_date: payment_info.payment_date.to_s,
              payment_status: payment_info.payment_status,
              pending_reason: payment_info.pending_reason,
              transaction_id: payment_info.transaction_id,
              order_total: payment_info.gross_amount.value,
              currency: payment_info.gross_amount.currency_id,
              secure_merchant_account_id: payment_info.seller_details.secure_merchant_account_id
            })
        }
      ),

      do_authorization: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            MsgSubID: req[:msg_sub_id],
            TransactionID: req[:transaction_id],
            Amount: {
              value: req[:order_total],
              currencyID: req[:currency]
            }
          }
        },
        wrapper_method_name: :build_do_authorization,
        action_method_name: :do_authorization,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_do_authorization_response({
            authorization_id: res.transaction_id,
            payment_status: res.authorization_info.payment_status,
            pending_reason: res.authorization_info.pending_reason,
            order_total: res.amount.value,
            currency: res.amount.currency_id,
            msg_sub_id: res.msg_sub_id
          })
        })
    }

  end
end
