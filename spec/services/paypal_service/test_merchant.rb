module PaypalService

  module TestMerchant
    def self.build(api_builder)
      PaypalService::Merchant.new(nil, TestLogger.new, TestActions.new.default_test_actions, api_builder)
    end
  end

  class TestApi
    attr_reader :config
    SuccessResponse = Struct.new(:success?, :value)
    ErrorResponse = Struct.new(:success?, :errors)
    Error = Struct.new(:error_code, :long_message)

    Config = Struct.new(:subject)

    def initialize(subject, should_fail = false, error_code = nil)
      @config = Config.new(subject || "test_username")
      @should_fail = should_fail
      @error_code = error_code
    end

    def wrap(val)
      unless @should_fail
        SuccessResponse.new(true, val)
      else
        ErrorResponse.new(false, [Error.new(@error_code, "error msg")])
      end
    end

    def do_nothing(val)
      val
    end
  end

  class TestApiBuilder
    def initialize()
      # We maintain a queue of next response type, elems are :ok or "error_code".
      # Empty queue implicitly means :ok
      @next_responses = []
    end

    def will_respond_with(response_types)
      @next_responses = response_types
    end

    def will_fail(times, error_code)
      will_respond_with(times.times.map { error_code })
    end

    def call(req)
      res_type = @next_responses.shift
      if (res_type.is_a? String)
        TestApi.new(req[:receiver_username], true, res_type)
      else
        TestApi.new(req[:receiver_username])
      end
    end
  end

  class FakePal
    def initialize
      @tokens = {}
      @payments_by_order_id = {}
      @payments_by_auth_id = {}
    end

    def save_token(req)
      token = {
        token: SecureRandom.uuid,
        item_name: req[:item_name],
        item_quantity: req[:item_quantity],
        item_price: req[:item_price],
        order_total: req[:order_total],
        receiver_id: req[:receiver_username]
      }

      @tokens[token[:token]] = token
      token
    end

    def get_token(token)
      @tokens[token]
    end

    def create_and_save_payment(token)
      payment = {
        order_date: Time.now,
        payment_status: "pending",
        pending_reason: "order",
        order_id: SecureRandom.uuid,
        order_total: token[:order_total],
        receiver_id: token[:receiver_id]
      }

      @payments_by_order_id[payment[:order_id]] = payment
      payment
    end

    def authorize_payment(order_id, authorization_total)
      payment = @payments_by_order_id[order_id]
      raise "No order with order id: #{order_id}" if payment.nil?
      raise "Cannot authorize more than order_total" if authorization_total.cents > payment[:order_total].cents

      auth_id = SecureRandom.uuid
      auth_payment = payment.merge({
        authorization_date: Time.now,
        authorization_total: authorization_total,
        authorization_id: auth_id,
        payment_status: "pending",
        pending_reason: "authorization",
        })

      @payments_by_order_id[order_id] = auth_payment
      @payments_by_auth_id[auth_id] = auth_payment
      auth_payment
    end

    def capture_payment(auth_id, payment_total)
      payment = @payments_by_auth_id[auth_id]
      raise "No payment for auth id: #{auth_id}" if payment.nil?
      raise "Cannot capture more than authorization_total" if payment_total.cents > payment[:authorization_total].cents

      payment_id = SecureRandom.uuid
      captured_payment = payment.merge({
          payment_id: payment_id,
          payment_total: payment_total,
          fee_total: Money.new((payment_total.cents*0.1).to_i, payment_total.currency.iso_code),
          payment_date: Time.now,
          payment_status: "completed",
          pending_reason: "none"
        })
    end

    def get_payment(auth_or_order_id)
      @payments_by_auth_id[auth_or_order_id] || @payments_by_order_id[auth_or_order_id]
    end

    def void(auth_or_order_id)
      payment = get_payment(auth_or_order_id)
      raise "No payment with order or auth id: #{auth_or_order_id}" if payment.nil?

      voided_payment = payment.merge({
          payment_status: "voided",
          pending_reason: "none"
        })

      @payments_by_order_id[voided_payment[:order_id]] = voided_payment
      @payments_by_auth_id[voided_payment[:authorization_id]] = voided_payment unless voided_payment[:authorization_id].nil?
      voided_payment
    end
  end

  # rubocop:disable all
  class TestActions
    attr_reader :default_test_actions

    def initialize
      @fake_pal = FakePal.new
      @default_test_actions = build_default_test_actions
    end

    def build_default_test_actions
      identity = -> (val, _) { val }

      {
        get_express_checkout_details: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.get_token(req[:token])

            if (!token.nil?)
              DataTypes::Merchant.create_get_express_checkout_details_response(
                {
                  token: token[:token],
                  checkout_status: "not_used_in_tests",
                  billing_agreement_accepted: true,
                  payer: token[:email],
                  payer_id: "payer_id",
                  order_total: token[:order_total]
                })
            else
              PaypalService::DataTypes::FailureResponse.call()
            end
          }
          ),

        set_express_checkout_order: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.save_token(req)

            DataTypes::Merchant.create_set_express_checkout_order_response({
                token: token[:token],
                redirect_url: "https://paypaltest.com/#{token[:token]}",
                receiver_username: api.config.subject || api.config.username
              })
          }
        ),

        do_express_checkout_payment: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.get_token(req[:token])

            if (!token.nil?)
              payment = @fake_pal.create_and_save_payment(token)
              DataTypes::Merchant.create_do_express_checkout_payment_response(
                {
                  order_date: payment[:order_date],
                  payment_status: payment[:payment_status],
                  pending_reason: payment[:pending_reason],
                  order_id: payment[:order_id],
                  order_total: payment[:order_total],
                  receiver_id: payment[:receiver_id]
                })
            else
              PaypalService::DataTypes::FailureResponse.call()
            end
          }
        ),

        do_authorization: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            payment = @fake_pal.authorize_payment(req[:order_id], req[:authorization_total])
            DataTypes::Merchant.create_do_authorization_response({
              authorization_id: payment[:authorization_id],
              payment_status: payment[:payment_status],
              pending_reason: payment[:pending_reason],
              authorization_total: payment[:authorization_total],
              authorization_date: payment[:authorization_date],
              msg_sub_id: req[:msg_sub_id]
            })
          }
        ),

        do_capture: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            payment = @fake_pal.capture_payment(req[:authorization_id], req[:payment_total])

            DataTypes::Merchant.create_do_full_capture_response(
              {
                authorization_id: payment[:authorization_id],
                payment_id: payment[:payment_id],
                payment_status: payment[:payment_status],
                pending_reason: payment[:pending_reason],
                payment_total: payment[:payment_total],
                fee_total: payment[:fee_total],
                payment_date: payment[:payment_date]
              }
            )
          }
        ),

        do_void: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            payment = @fake_pal.void(req[:transaction_id])
            DataTypes::Merchant.create_do_void_response(
              {
                voided_id: req[:transaction_id],
                msg_sub_id: req[:msg_sub_id]
              }
            )
          }
        ),

        get_transaction_details: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            payment = @fake_pal.get_payment(req[:transaction_id])

            DataTypes::Merchant.create_get_transaction_details_response(
              {
                transaction_id: req[:transaction_id],
                payment_status: payment[:payment_status],
                pending_reason: payment[:pending_reason],
                transaction_total: payment[:order_total]
              }
            )
          }
        ),

        do_reference_transaction: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]

            DataTypes::Merchant.create_do_reference_transaction_response({
              billing_agreement_id: req[:billing_agreement_id],
              payment_id: SecureRandom.uuid,
              payment_total: req[:payment_total],
              payment_date: Time.now,
              fee: Money.new((req[:payment_total].cents*0.1).to_i, req[:payment_total].currency.iso_code),
              payment_status: "completed",
              pending_reason: "none",
              username_to: api.config.subject || api.config.username
            })
          }
        ),
      }
    end
  end
  # rubocop:enable all

end
