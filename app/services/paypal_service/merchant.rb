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

      raise(ArgumentException, "Unknown request method #{request.method}")
    end

    private

    def do_setup_billing_agreement(req)
      set_express_checkout = @api.build_set_express_checkout({
        SetExpressCheckoutRequestDetails: {
          ReturnURL: req.success,
          CancelURL: req.cancel,
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
      if (res.success?)
        DataTypes::Merchant.create_setup_billing_agreement_response(
          res.token, @api.express_checkout_url(res))
      else
        if (res.errors.length > 0)
          DataTypes::Merchant.create_failed_setup_billing_agreement_response(res.errors[0].error_code, res.errors[0].long_message)
        else
          DataTypes::Merchant.create_failed_setup_billing_agreement_response()
        end
      end
    end
  end
end
