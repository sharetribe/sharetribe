require_relative 'test_api'

module PaypalService

  module TestMerchant
    def self.build(api_builder, store)
      PaypalService::Merchant.new(nil, TestLogger.new, TestMerchantActions.new(store).default_test_actions, api_builder)
    end
  end

  class FakePalMerchant
    def initialize(store)
      @tokens = store.namespace(:merchant, :tokens)
      @payments_by_order_id = store.namespace(:merchant, :payments_by_order_id)
      @payments_by_auth_id = store.namespace(:merchant, :payments_by_auth_id)
      @billing_agreements_by_token = store.namespace(:merchant, :billing_agreements_by_token)
    end

    def save_token(req, payment_action)
      token = {
        token: SecureRandom.uuid,
        payment_action: payment_action,
        item_name: req[:item_name],
        item_quantity: req[:item_quantity],
        item_price: req[:item_price],
        order_total: req[:order_total],
        receiver_id: req[:receiver_username],
        no_shipping: req[:require_shipping_address] ? 0 : 1
      }

      @tokens[token[:token]] = token
      token
    end

    def get_token(token)
      @tokens[token]
    end

    def create_and_save_payment(token)
      if token[:payment_action] == :order
        create_and_save_order_payment(token)
      else
        create_and_save_auth_payment(token)
      end
    end

    def create_and_save_order_payment(token)
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

    def create_and_save_auth_payment(token)
      # Allows test calls to inject payment-review response status
      require_payment_review = token[:item_name] == "require-payment-review"

      payment = {
        authorization_date: Time.now,
        payment_status: "pending",
        pending_reason: require_payment_review ? "payment-review" : "authorization",
        authorization_id: SecureRandom.uuid,
        authorization_total: token[:order_total],
        receiver_id: token[:receiver_id]
      }

      @payments_by_auth_id[payment[:authorization_id]] = payment
      payment
    end

    def create_and_save_billing_agreement(token)
      billing_agreement = {
        billing_agreement_id: SecureRandom.uuid
      }

      @billing_agreements_by_token[token[:token]] = billing_agreement
      billing_agreement
    end

    def authorize_payment(order_id, authorization_total)
      payment = @payments_by_order_id[order_id]
      raise "No order with order id: #{order_id}" if payment.nil?
      raise "Cannot authorize more than order_total" if authorization_total.cents > payment[:order_total].cents
      raise "Cannot authorize already authorized payment" if payment[:pending_reason] != "order"

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

    def get_billing_agreement(token)
      @billing_agreements_by_token[token[:token]]
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
  class TestMerchantActions
    attr_reader :default_test_actions

    def initialize(store)
      @fake_pal = FakePalMerchant.new(store)
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
            billing_agreement = @fake_pal.get_billing_agreement(token)

            if (!token.nil?)
              response = {
                token: token[:token],
                checkout_status: "not_used_in_tests",
                billing_agreement_accepted: !billing_agreement.nil?,
                payer: token[:email],
                payer_id: token[:item_name] != "payment-not-initiated" ? "payer_id" : nil,
                order_total: token[:order_total]
              }

              if(token[:no_shipping] == 0)
                response[:shipping_address_status] = "Confirmed"
                response[:shipping_address_city] = "city"
                response[:shipping_address_country] = "country"
                response[:shipping_address_country_code] = "CC"
                response[:shipping_address_name] = "name"
                response[:shipping_address_phone] = "123456"
                response[:shipping_address_postal_code] = "WX1GQ"
                response[:shipping_address_state_or_province] = "state"
                response[:shipping_address_street1] = "street1"
                response[:shipping_address_street2] = "street2"
              end

              DataTypes::Merchant.create_get_express_checkout_details_response(response)
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
            token = @fake_pal.save_token(req, :order)

            DataTypes::Merchant.create_set_express_checkout_order_response({
                token: token[:token],
                redirect_url: "https://paypaltest.com/#{token[:token]}",
                receiver_username: api.config.subject || api.config.username
              })
          }
        ),

        set_express_checkout_authorization: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.save_token(req, :authorization)

            redirect_url = URLUtils.append_query_param(req[:success], :token, token[:token])

            DataTypes::Merchant.create_set_express_checkout_order_response({
                token: token[:token],
                redirect_url: redirect_url,
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
              DataTypes::Merchant.create_do_express_checkout_payment_response(payment)
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

        setup_billing_agreement: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.save_token({}, :authorization)

            redirect_url = URLUtils.append_query_param(req[:success], :token, token[:token])

            DataTypes::Merchant.create_setup_billing_agreement_response(
              {
                token: token[:token],
                redirect_url: redirect_url,
                username_to: api.config.subject || api.config.username
              }
            )
          }
        ),

        create_billing_agreement: PaypalAction.def_action(
          input_transformer: identity,
          wrapper_method_name: :do_nothing,
          action_method_name: :wrap,
          output_transformer: -> (res, api) {
            req = res[:value]
            token = @fake_pal.get_token(req[:token])

            if (!token.nil?)
              billing_agreement = @fake_pal.create_and_save_billing_agreement(token)

              DataTypes::Merchant.create_create_billing_agreement_response(
                billing_agreement_id: billing_agreement[:billing_agreement_id]
              )
            else
              PaypalService::DataTypes::FailureResponse.call()
            end
          }
        )
      }
    end
  end
  # rubocop:enable all

end
