module PaypalService
  class Merchant

    def initialize(endpoint, api_credentials, logger)
      @logger = logger

      PayPal::SDK.configure({
        mode: endpoint.endpoint_name.to_s,
        username: api_credentials.username,
        password: api_credentials.password,
        signature: api_credentials.signature,
        app_id: api_credentials.app_id
      })
    end

    def do_request(request)
      return do_setup_billing_agreement(request) if request.method == :setup_billing_agreement
      return do_create_billing_agreement(request) if request.method == :create_billing_agreement
      return do_do_reference_transaction(request) if request.method == :do_reference_transaction

      raise(ArgumentException, "Unknown request method #{request.method}")
    end

    def build_api(subject = nil)
      if (subject)
        PayPal::SDK::Merchant.new(nil, { subject: subject })
      else
        PayPal::SDK::Merchant.new
      end
    end


    private

    def subject(api)
      api.config.subject || api.config.username
    end

    def do_setup_billing_agreement(req)
      api = build_api
      set_express_checkout = api.build_set_express_checkout({
        SetExpressCheckoutRequestDetails: {
          ReturnURL: req.success,
          CancelURL: req.cancel,
          ReqConfirmShipping: 0,
          NoShipping: 1,
          PaymentDetails: [{
            OrderTotal: {value: "0.0"},
            # NotifyURL: "https://paypal-sdk-samples.herokuapp.com/merchant/ipn_notify",
            PaymentAction: "Authorization"
          }],
          BillingAgreementDetails: [{
            BillingType: "ChannelInitiatedBilling",
            BillingAgreementDescription: req.description
          }]
        }
      })

      res = api.set_express_checkout(set_express_checkout)
      @logger.log_response(res)

      if (res.success?)
        DataTypes::Merchant.create_setup_billing_agreement_response(
          res.token, api.express_checkout_url(res), subject(api))
      else
        create_failure_response(res)
      end
    end

    def do_create_billing_agreement(req)
      api = build_api
      create_billing_agreement = api.build_create_billing_agreement({Token: req.token})

      res = api.create_billing_agreement(create_billing_agreement)
      @logger.log_response(res)

      if (res.success?)
        DataTypes::Merchant.create_create_billing_agreement_response(res.billing_agreement_id)
      else
        create_failure_response(res)
      end
    end

    def do_do_reference_transaction(req)
      api = build_api(req.receiver_username)
      do_ref_tx = api.build_do_reference_transaction({
        DoReferenceTransactionRequestDetails: {
          ReferenceID: req.billing_agreement_id,
          PaymentAction: "Sale",
          PaymentDetails: {
            OrderTotal: {
              currencyID: req.currency,
              value: req.order_total
            }
          }
        }
      })

      res = api.do_reference_transaction(do_ref_tx)
      @logger.log_response(res)

      if (res.success?)
        details = res.do_reference_transaction_response_details
        DataTypes::Merchant.create_do_reference_transaction_response(
          details.billing_agreement_id,
          details.payment_info.transaction_id,
          details.payment_info.gross_amount.value,
          details.payment_info.gross_amount.currency_id,
          details.payment_info.fee_amount.value,
          details.payment_info.fee_amount.currency_id,
          subject(api))
      else
        create_failure_response(res)
      end
    end


    def create_failure_response(res)
      if (res.errors.length > 0)
        DataTypes.create_failure_response(
          res.errors[0].error_code, res.errors[0].long_message)
      else
        DataTypes.create_failure_response()
      end
    end
  end
end
