module PaypalService
  module MerchantActions

    module_function

    # Convert between a Money instance and corresponding Paypal API presentation
    # pp API present amounts as hash-like objects, e.g. : { value: "17.12", currencyID: "EUR" }

    def from_money(m)
      { value: MoneyUtil.to_dot_separated_str(m), currencyID: m.currency.iso_code }
    end

    def to_money(pp_amount)
      pp_amount.value.to_money(pp_amount.currency_id) unless (pp_amount.nil? || pp_amount.value.nil?)
    end


    def hook_url(ipn_hook)
      ipn_hook[:url] unless ipn_hook.nil?
    end

    def append_useraction_commit(url_str)
      URLUtils.append_query_param(url_str, "useraction", "commit")
    end


    PAYMENT_ACTIONS = { sale: "Sale", order: "Order", authorization: "Authorization" }

    def payment_action_str(payment_action_symbol)
      str = PAYMENT_ACTIONS[payment_action_symbol]
      if str.nil?
        raise ArgumentError.new("Unsupported payment action: #{payment_action_symbol}")
      end

      str
    end


    # Use either the default old checkout UI or the new paypal checkout experience
    NEW_CHECKOUT_UI = false

    # URLs for the new paypal checkout UI
    SANDBOX_EC_URL = "https://www.sandbox.paypal.com/checkoutnow"
    LIVE_EC_URL = "https://www.paypal.com/checkoutnow"
    TOKEN_PARAM = "token"

    def express_checkout_url(api, token)
      if NEW_CHECKOUT_UI
        endpoint = api.config.mode.to_sym
        if (endpoint == :sandbox)
          URLUtils.append_query_param(SANDBOX_EC_URL, TOKEN_PARAM, token)
        else
          URLUtils.append_query_param(LIVE_EC_URL, TOKEN_PARAM, token)
        end
      else
        api.express_checkout_url(token)
      end
    end


    MERCHANT_ACTIONS = {
      setup_billing_agreement: PaypalAction.def_action(
        input_transformer: -> (req, config) {
          {
            SetExpressCheckoutRequestDetails: {
              ReturnURL: req[:success],
              CancelURL: req[:cancel],
              ReqConfirmShipping: 0,
              NoShipping: 1,
              AllowNote: 0,
              PaymentDetails: [{
                  OrderTotal: { value: "0.0" },
                  NotifyURL: hook_url(config[:ipn_hook]),
                  PaymentAction: PAYMENT_ACTIONS[:authorization],
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
            redirect_url: express_checkout_url(api, res.token),
            username_to: api.config.subject || api.config.username
          })
        }
      ),

      create_billing_agreement: PaypalAction.def_action(
        input_transformer: -> (req, _) { { Token: req[:token] } },
        wrapper_method_name: :build_create_billing_agreement,
        action_method_name: :create_billing_agreement,
        output_transformer: -> (res, _) {
          DataTypes::Merchant.create_create_billing_agreement_response({
            billing_agreement_id: res.billing_agreement_id
          })
        }
      ),

      do_reference_transaction: PaypalAction.def_action(
        input_transformer: -> (req, config) {
          {
            DoReferenceTransactionRequestDetails: {
              ReferenceID: req[:billing_agreement_id],
              PaymentAction: PAYMENT_ACTIONS[:sale],
              PaymentType: "InstantOnly",
              PaymentDetails: {
                ButtonSource: config[:button_source],
                NotifyURL: hook_url(config[:ipn_hook]),
                OrderTotal: from_money(req[:payment_total]),
                InvoiceID: req[:invnum],
                PaymentDetailsItem: [{
                    ItemCategory: "Digital", #Commissions are always digital goods, enables also micropayments
                    Name: req[:name],
                    Description: req[:desc],
                    Number: 0,
                    Quantity: 1,
                    Amount: from_money(req[:payment_total])
                }]
              },
              MsgSubID: req[:msg_sub_id]
            }
          }
        },
        wrapper_method_name: :build_do_reference_transaction,
        action_method_name: :do_reference_transaction,
        output_transformer: -> (res, api) {
          details = res.do_reference_transaction_response_details
          DataTypes::Merchant.create_do_reference_transaction_response({
            billing_agreement_id: details.billing_agreement_id,
            payment_id: details.payment_info.transaction_id,
            payment_total: to_money(details.payment_info.gross_amount),
            payment_date: details.payment_info.payment_date.to_s,
            fee: to_money(details.payment_info.fee_amount),
            payment_status: details.payment_info.payment_status,
            pending_reason: details.payment_info.pending_reason,
            username_to: api.config.subject || api.config.username
          })
        }
      ),

      get_express_checkout_details: PaypalAction.def_action(
        input_transformer: -> (req, _) { { Token: req[:token] } },
        wrapper_method_name: :build_get_express_checkout_details,
        action_method_name: :get_express_checkout_details,
        output_transformer: -> (res, api) {
          details = res.get_express_checkout_details_response_details
          shipping_address = details.payment_details[0].ship_to_address
          DataTypes::Merchant.create_get_express_checkout_details_response(
            {
              token: details.token,
              checkout_status: details.checkout_status,
              billing_agreement_accepted: !!details.billing_agreement_accepted_status,
              payer: details.payer_info.payer,
              payer_id: details.payer_info.payer_id,
              order_total: to_money(details.payment_details[0].order_total),
              shipping_address_status: shipping_address.address_status,
              shipping_address_city: shipping_address.city_name,
              shipping_address_country: shipping_address.country_name,
              shipping_address_country_code: shipping_address.country,
              shipping_address_name: shipping_address.name,
              shipping_address_phone: shipping_address.phone,
              shipping_address_postal_code: shipping_address.postal_code,
              shipping_address_state_or_province: shipping_address.state_or_province,
              shipping_address_street1: shipping_address.street1,
              shipping_address_street2: shipping_address.street2
            }
          )
        }
      ),

      # Deprecated - Order flow will be removed soon
      #
      set_express_checkout_order: PaypalAction.def_action(
        input_transformer: -> (req, config) {
          req_details = {
            cppcartbordercolor: "FFFFFF",
            cpplogoimage: req[:merchant_brand_logo_url] || "",
            ReturnURL: req[:success],
            CancelURL: req[:cancel],
            ReqConfirmShipping: 0,
            NoShipping: req[:require_shipping_address] ? 0 : 1,
            SolutionType: "Sole",
            LandingPage: "Billing",
            InvoiceID: req[:invnum],
            AllowNote: 0,
            MaxAmount: from_money(req[:order_total]),
            PaymentDetails: [{
              NotifyURL: hook_url(config[:ipn_hook]),
              OrderTotal: from_money(req[:order_total]),
              ItemTotal: from_money(req[:item_price] * req[:item_quantity]),
              PaymentAction: PAYMENT_ACTIONS[:order],
              PaymentDetailsItem: [{
                Name: req[:item_name],
                Quantity: req[:item_quantity],
                Amount: from_money(req[:item_price])
              }]
            }]
          }

          if(req[:shipping_total])
             req_details[:PaymentDetails][0][:ShippingTotal] = from_money(req[:shipping_total])
          end

          { SetExpressCheckoutRequestDetails: req_details }
        },
        wrapper_method_name: :build_set_express_checkout,
        action_method_name: :set_express_checkout,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_set_express_checkout_order_response({
            token: res.token,
            redirect_url: append_useraction_commit(express_checkout_url(api, res.token)),
            receiver_username: api.config.subject || api.config.username
          })
        }
      ),
      #
      # /Deprecated

      set_express_checkout_authorization: PaypalAction.def_action(
        input_transformer: -> (req, config) {
          req_details = {
            cppcartbordercolor: "FFFFFF",
            cpplogoimage: req[:merchant_brand_logo_url] || "",
            ReturnURL: req[:success],
            CancelURL: req[:cancel],
            ReqConfirmShipping: 0,
            NoShipping: req[:require_shipping_address] ? 0 : 1,
            SolutionType: "Sole",
            LandingPage: "Billing",
            InvoiceID: req[:invnum],
            AllowNote: 0,
            MaxAmount: from_money(req[:order_total]),
            PaymentDetails: [{
              NotifyURL: hook_url(config[:ipn_hook]),
              OrderTotal: from_money(req[:order_total]),
              ItemTotal: from_money(req[:item_price] * req[:item_quantity]),
              PaymentAction: PAYMENT_ACTIONS[:authorization],
              PaymentDetailsItem: [{
                Name: req[:item_name],
                Quantity: req[:item_quantity],
                Amount: from_money(req[:item_price])
              }]
            }]
          }

          if(req[:shipping_total])
             req_details[:PaymentDetails][0][:ShippingTotal] = from_money(req[:shipping_total])
          end

          { SetExpressCheckoutRequestDetails: req_details }
        },
        wrapper_method_name: :build_set_express_checkout,
        action_method_name: :set_express_checkout,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_set_express_checkout_order_response({
            token: res.token,
            redirect_url: append_useraction_commit(express_checkout_url(api, res.token)),
            receiver_username: api.config.subject || api.config.username
          })
        }
      ),

      do_express_checkout_payment: PaypalAction.def_action(
        input_transformer: -> (req, config) {
          req_details = {
            PaymentAction: payment_action_str(req[:payment_action]),
            Token: req[:token],
            PayerID: req[:payer_id],
            ButtonSource: config[:button_source],
            PaymentDetails: [{
              InvoiceID: req[:invnum],
              NotifyURL: hook_url(config[:ipn_hook]),
              OrderTotal: from_money(req[:order_total]),
              ItemTotal: from_money(req[:item_price] * req[:item_quantity]),
              PaymentDetailsItem: [{
                Name: req[:item_name],
                Quantity: req[:item_quantity],
                Amount: from_money(req[:item_price])
              }]
            }]
          }

          if(req[:shipping_total])
            req_details[:PaymentDetails][0][:ShippingTotal] = from_money(req[:shipping_total])
            req_details[:PaymentDetails][0][:ShipToAddress] = {
              Name: req[:shipping_address_name],
              Phone: req[:shipping_address_phone],
              Street1: req[:shipping_address_street1],
              Street2: req[:shipping_address_street2],
              PostalCode: req[:shipping_address_postal_code],
              CityName: req[:shipping_address_city],
              StateOrProvince: req[:shipping_address_state_or_province],
              Country: req[:shipping_address_country_code]
            }
          end

          { DoExpressCheckoutPaymentRequestDetails: req_details }
        },
        wrapper_method_name: :build_do_express_checkout_payment,
        action_method_name: :do_express_checkout_payment,
        output_transformer: -> (res, api) {
          payment_info = res.do_express_checkout_payment_response_details.payment_info[0]

          if (payment_info.pending_reason == "order")
            DataTypes::Merchant.create_do_express_checkout_payment_response(
              {
                order_date: payment_info.payment_date.to_s,
                payment_status: payment_info.payment_status,
                pending_reason: payment_info.pending_reason,
                order_id: payment_info.transaction_id,
                order_total: to_money(payment_info.gross_amount)
              })
          else
            DataTypes::Merchant.create_do_express_checkout_payment_response(
              {
                authorization_date: payment_info.payment_date.to_s,
                payment_status: payment_info.payment_status,
                pending_reason: payment_info.pending_reason,
                authorization_id: payment_info.transaction_id,
                authorization_total: to_money(payment_info.gross_amount)
              })
          end
        }
      ),

      do_authorization: PaypalAction.def_action(
        input_transformer: -> (req, _) {
          {
            MsgSubID: req[:msg_sub_id],
            TransactionID: req[:order_id],
            Amount: from_money(req[:authorization_total]),
          }
        },
        wrapper_method_name: :build_do_authorization,
        action_method_name: :do_authorization,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_do_authorization_response({
            authorization_id: res.transaction_id,
            payment_status: res.authorization_info.payment_status,
            pending_reason: res.authorization_info.pending_reason,
            authorization_total: to_money(res.amount),
            authorization_date: res.timestamp.to_s,
            msg_sub_id: res.msg_sub_id
          })
        }
      ),

      do_capture: PaypalAction.def_action(
        input_transformer: -> (req, _) {
          {
            AuthorizationID: req[:authorization_id],
            Amount: from_money(req[:payment_total]),
            InvoiceID: req[:invnum],
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
              payment_id: payment_info.transaction_id,
              payment_status: payment_info.payment_status,
              pending_reason: payment_info.pending_reason,
              payment_total: to_money(payment_info.gross_amount),
              fee_total: to_money(payment_info.fee_amount),
              payment_date: payment_info.payment_date.to_s
            }
          )
        }
      ),

      do_void: PaypalAction.def_action(
        input_transformer: -> (req, _) {
          {
            AuthorizationID: req[:transaction_id],
            Note: req[:note],
            MsgSubID: req[:msg_sub_id]
          }
        },
        wrapper_method_name: :build_do_void,
        action_method_name: :do_void,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_do_void_response(
            {
              voided_id: res.authorization_id,
              msg_sub_id: res.msg_sub_id
            }
          )
        }
      ),

      refund_transaction: PaypalAction.def_action(
        input_transformer: -> (req, _) {
          {
            TransactionID: req[:payment_id],
            RefundType: "Full",
            RefundSource: "default",
            MsgSubID: req[:msg_sub_id]
          }
        },
        wrapper_method_name: :build_refund_transaction,
        action_method_name: :refund_transaction,
        output_transformer: -> (res, api) {
          DataTypes::Merchant.create_refund_transaction_response(
            {
              refunded_id: res.RefundTransactionID,
              refunded_fee_total: to_money(res.FeeRefundAmount),
              refunded_net_total: to_money(res.NetRefundAmount),
              refunded_gross_total: to_money(res.GrossRefundAmount),
              refunded_total: to_money(res.TotalRefundedAmount),
              msg_sub_id: res.MsgSubID
            }
          )
        }
      ),

      get_transaction_details: PaypalAction.def_action(
        input_transformer: -> (req, _) {
          {
            TransactionID: req[:transaction_id],
          }
        },
        wrapper_method_name: :build_get_transaction_details,
        action_method_name: :get_transaction_details,
        output_transformer: -> (res, api) {
          payment_info = res.payment_transaction_details.payment_info
          DataTypes::Merchant.create_get_transaction_details_response(
            {
              transaction_id: payment_info.transaction_id,
              payment_status: payment_info.payment_status,
              pending_reason: payment_info.pending_reason,
              transaction_total: to_money(payment_info.gross_amount)
            }
          )
        }
      )
    }

  end
end
