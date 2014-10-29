module PaypalService

  module TestMerchant
    def self.build
      PaypalService::Merchant.new(nil, TestLogger.new, TestActions.new.default_test_actions, TestApi.api_builder)
    end
  end

  class TestApi
    attr_reader :config
    WrappedResponse = Struct.new(:success?, :value)
    Config = Struct.new(:subject)

    def initialize(subject)
      @config = Config.new(subject || "test_username")
    end

    def wrap_success(val); WrappedResponse.new(true, val) end
    def wrap_failure(val); WrappedResponse.new(false, val) end
    def do_nothing(val); val end

    def self.api_builder
      -> (req) {
        TestApi.new(req[:receiver_username])
      }
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
  end

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
          action_method_name: :wrap_success,
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
          action_method_name: :wrap_success,
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
          action_method_name: :wrap_success,
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
          action_method_name: :wrap_success,
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
        )#,

        # do_capture: PaypalAction.def_action(
        #   input_transformer: -> (req, _) {
        #     {
        #       AuthorizationID: req[:authorization_id],
        #       Amount: from_money(req[:payment_total]),
        #       InvoiceID: req[:invnum],
        #       CompleteType: "Complete"
        #     }
        #   },
        #   wrapper_method_name: :build_do_capture,
        #   action_method_name: :do_capture,
        #   output_transformer: -> (res, api) {
        #     payment_info = res.do_capture_response_details.payment_info
        #     DataTypes::Merchant.create_do_full_capture_response(
        #       {
        #         authorization_id: res.do_capture_response_details.authorization_id,
        #         payment_id: payment_info.transaction_id,
        #         payment_status: payment_info.payment_status,
        #         pending_reason: payment_info.pending_reason,
        #         payment_total: to_money(payment_info.gross_amount),
        #         fee_total: to_money(payment_info.fee_amount),
        #         payment_date: payment_info.payment_date.to_s
        #       }
        #     )
        #   }
        # ),

        # do_void: PaypalAction.def_action(
        #   input_transformer: -> (req, _) {
        #     {
        #       AuthorizationID: req[:transaction_id],
        #       Note: req[:note],
        #       MsgSubID: req[:msg_sub_id]
        #     }
        #   },
        #   wrapper_method_name: :build_do_void,
        #   action_method_name: :do_void,
        #   output_transformer: -> (res, api) {
        #     DataTypes::Merchant.create_do_void_response(
        #       {
        #         voided_id: res.authorization_id,
        #         msg_sub_id: res.msg_sub_id
        #       }
        #     )
        #   }
        # ),

        # get_transaction_details: PaypalAction.def_action(
        #   input_transformer: -> (req, _) {
        #     {
        #       TransactionID: req[:transaction_id],
        #     }
        #   },
        #   wrapper_method_name: :build_get_transaction_details,
        #   action_method_name: :get_transaction_details,
        #   output_transformer: -> (res, api) {
        #     payment_info = res.payment_transaction_details.payment_info
        #     DataTypes::Merchant.create_get_transaction_details_response(
        #       {
        #         transaction_id: payment_info.transaction_id,
        #         payment_status: payment_info.payment_status,
        #         pending_reason: payment_info.pending_reason,
        #         transaction_total: to_money(payment_info.gross_amount)
        #       }
        #     )
        #   }
        # )
      }
    end

  end
end
