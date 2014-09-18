module PaypalService
  class Merchant

    ACTION_HANDLERS = {
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
      )
    }

    def initialize(endpoint, api_credentials, logger, action_handlers = ACTION_HANDLERS, api_builder = nil)
      @logger = logger
      @api_builder = api_builder || self.method(:build_api)
      @action_handlers = action_handlers

      PayPal::SDK.configure(
        {
         mode: endpoint[:endpoint_name].to_s,
         username: api_credentials[:username],
         password: api_credentials[:password],
         signature: api_credentials[:signature],
         app_id: api_credentials[:app_id]
        }
      )
    end

    def do_request(request)
      action_def = @action_handlers[request[:method]]
      return exec_action(action_def, @api_builder.call(request), request) if action_def

      raise(ArgumentException, "Unknown request method #{request.method}")
    end


    def build_api(request)
      req = request.to_h
      if (req[:receiver_username])
        PayPal::SDK::Merchant.new(nil, { subject: req[:receiver_username] })
      else
        PayPal::SDK::Merchant.new
      end
    end


    private

    def exec_action(action_def, api, request)
      input_transformer = action_def[:input_transformer]
      wrapper_method = api.method(action_def[:wrapper_method_name])
      action_method = api.method(action_def[:action_method_name])
      output_transformer = action_def[:output_transformer]

      input = input_transformer.call(request)
      wrapped = wrapper_method.call(input)
      response = action_method.call(wrapped)

      @logger.log_response(response)
      if (response.success?)
        output_transformer.call(response, api)
      else
        create_failure_response(response)
      end
    end


    def create_failure_response(res)
      if (res.errors.length > 0)
        DataTypes.create_failure_response({
          error_code: res.errors[0].error_code,
          error_msg: res.errors[0].long_message
        })
      else
        DataTypes.create_failure_response({})
      end
    end
  end
end
