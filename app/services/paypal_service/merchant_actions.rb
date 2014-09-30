module PaypalService
  module MerchantActions

    module_function

    # Convert between a Money instance and corresponding Paypal API presentation
    # pp API present amounts as hash-like objects, e.g. : { value: "17.12", currencyID: "EUR" }

    def from_money(m)
      { value: m.to_s, currencyID: m.currency.iso_code }
    end

    def to_money(pp_amount)
      pp_amount.value.to_money(pp_amount.currency_id)
    end


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
                  OrderTotal: { value: "0.0" },
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
              PaymentDetails: { OrderTotal: from_money(req[:order_total]) }
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
            order_total: to_money(details.payment_info.gross_amount),
            fee: to_money(details.payment_info.fee_amount),
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
          DataTypes::Merchant.create_get_express_checkout_details_response(
            {
              token: details.token,
              checkout_status: details.checkout_status,
              billing_agreement_accepted: !!details.billing_agreement_accepted_status,
              payer: details.payer_info.payer,
              payer_id: details.payer_info.payer_id,
              order_total: to_money(details.payment_details[0].order_total),
            }
          )
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
                  OrderTotal: from_money(req[:order_total]),
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
                  OrderTotal: from_money(req[:order_total])
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
              order_total: to_money(payment_info.gross_amount),
              secure_merchant_account_id: payment_info.seller_details.secure_merchant_account_id
            })
        }
      ),

      do_authorization: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            MsgSubID: req[:msg_sub_id],
            TransactionID: req[:transaction_id],
            Amount: from_money(req[:order_total]),
          }
        },
        wrapper_method_name: :build_do_authorization,
        action_method_name: :do_authorization,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_do_authorization_response({
            authorization_id: res.transaction_id,
            payment_status: res.authorization_info.payment_status,
            pending_reason: res.authorization_info.pending_reason,
            order_total: to_money(res.amount),
            msg_sub_id: res.msg_sub_id
          })
        }
      ),

      do_capture: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            AuthorizationID: req[:authorization_id],
            Amount: from_money(req[:order_total]),
            CompleteType: "Complete"
          }
        },
        wrapper_method_name: :build_do_capture,
        action_method_name: :do_capture,
        output_transformer: -> (res, api) {
          payment_info = res.do_capture_response_details.payment_info
          DataTypes::Merchant.create_do_full_capture_response(
            {
              authorization_id: res.do_capture_response_details.authorization_id,
              transaction_id: payment_info.transaction_id,
              payment_status: payment_info.payment_status,
              pending_reason: payment_info.pending_reason,
              order_total: to_money(payment_info.gross_amount),
              fee: to_money(payment_info.fee_amount),
              payment_date: payment_info.payment_date.to_s
            }
          )
        }
      ),

      do_void: PaypalAction.def_action(
        input_transformer: -> (req) {
          {
            AuthorizationID: req[:authorization_id],
            Note: req[:note],
            MsgSubID: req[:msg_sub_id]
          }
        },
        wrapper_method_name: :build_do_void,
        action_method_name: :do_void,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_do_void_response(
            {
              authorization_id: res.authorization_id,
              msg_sub_id: res.msg_sub_id
            }
          )
        }
      )
    }

  end
end
