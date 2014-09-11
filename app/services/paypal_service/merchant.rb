module PaypalService
  class Merchant

    attr_reader :api

    def initialize(endpoint, api_credentials, logger)
      @logger = logger

      PayPal::SDK.configure({
        mode: endpoint.endpoint_name.to_s,
        username: api_credentials.username,
        password: api_credentials.password,
        signature: api_credentials.signature,
        app_id: api_credentials.app_id
      })

      @api = PayPal::SDK::Merchant.new
    end

    def do_request(request)
      return do_setup_billing_agreement(request) if request.method == :setup_billing_agreement
      return do_create_billing_agreement(request) if request.method == :create_billing_agreement

      raise(ArgumentException, "Unknown request method #{request.method}")
    end

    private

    def do_setup_billing_agreement(req)
      set_express_checkout = @api.build_set_express_checkout({
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
            BillingType: "MerchantInitiatedBillingSingleAgreement",
            BillingAgreementDescription: req.description
          }]
        }
      })

      res = @api.set_express_checkout(set_express_checkout)
      @logger.log_response(res)

      if (res.success?)
        DataTypes::Merchant.create_setup_billing_agreement_response(
          res.token, @api.express_checkout_url(res))
      else
        create_failure_response(res)
      end
    end

    def do_create_billing_agreement(req)
      create_billing_agreement = @api.build_create_billing_agreement({Token: req.token})

      res = @api.create_billing_agreement(create_billing_agreement)
      @logger.log_response(res)

      if (res.success?)
        DataTypes::Merchant.create_create_billing_agreement_response(res.billing_agreement_id)
      else
        create_failure_response(res)
      end
    end


    def create_failure_response(res)
      if (res.errors.length > 0)
        DataTypes.create_failure_response(res.errors[0].error_code, res.errors[0].long_message)
      else
        DataTypes.create_failure_response()
      end
    end
  end
end
