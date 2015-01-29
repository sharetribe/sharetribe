require_relative 'test_api'

module PaypalService

  module TestMerchant
    def self.build(api_builder)
      PaypalService::Merchant.new(nil, TestLogger.new, TestMerchantActions.new.default_test_actions, api_builder)
    end
  end

  # rubocop:disable all
  class TestMerchantActions
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
                  order_total: payment[:order_total]
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
