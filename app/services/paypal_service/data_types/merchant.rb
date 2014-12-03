module PaypalService
  module DataTypes

    module Merchant

      SetupBillingAgreement = EntityUtils.define_builder(
        [:method, const_value: :setup_billing_agreement],
        [:description, :mandatory, :string],
        [:success, :mandatory, :string],
        [:cancel, :mandatory, :string])

      SetupBillingAgreementResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:token, :mandatory, :string],
        [:redirect_url, :mandatory, :string],
        [:username_to, :mandatory, :string])

      CreateBillingAgreement = EntityUtils.define_builder(
        [:method, const_value: :create_billing_agreement],
        [:token, :mandatory, :string])

      CreateBillingAgreementResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:billing_agreement_id, :mandatory, :string])

      DoReferenceTransaction = EntityUtils.define_builder(
        [:method, const_value: :do_reference_transaction],
        [:receiver_username, :mandatory, :string],
        [:billing_agreement_id, :mandatory, :string],
        [:payment_total, :mandatory, :money],
        [:name, :string, :mandatory],
        [:desc, :string],
        [:invnum, :string, :mandatory], # Unique tx id on our side
        [:msg_sub_id, transform_with: -> (v) { v.nil? ? SecureRandom.uuid : v }])

      DoReferenceTransactionResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:billing_agreement_id, :mandatory, :string],
        [:payment_status, :mandatory, :string],
        [:pending_reason, :string],
        [:payment_id, :mandatory, :string],
        [:payment_total, :mandatory, :money],
        [:payment_date, :utc_str_to_time],
        [:fee, :money],
        [:username_to, :mandatory, :string])

      GetExpressCheckoutDetails = EntityUtils.define_builder(
        [:method, const_value: :get_express_checkout_details],
        [:receiver_username, :optional, :string],
        [:token, :mandatory, :string])

      GetExpressCheckoutDetailsResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:token, :mandatory, :string],
        [:checkout_status, :mandatory, :string],
        [:billing_agreement_accepted],
        [:payer, :string],
        [:payer_id, :string],
        [:order_total, :mandatory, :money])

      SetExpressCheckoutOrder = EntityUtils.define_builder(
        [:method, const_value: :set_express_checkout_order],
        [:item_name, :mandatory, :string],
        [:item_quantity, :fixnum, default: 1],

        # If not specified, defaults to order_total. If specifed, quantity * item_price must match order_total
        [:item_price, :optional, :money],

        [:receiver_username, :mandatory, :string],
        [:order_total, :mandatory, :money],
        [:success, :mandatory, :string],
        [:cancel, :mandatory, :string],
        [:invnum, :mandatory, :string],
        [:merchant_brand_logo_url, :optional, :string])

      SetExpressCheckoutOrderResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:token, :mandatory, :string],
        [:redirect_url, :mandatory, :string],
        [:receiver_username, :mandatory, :string])

      DoExpressCheckoutPayment = EntityUtils.define_builder(
        [:method, const_value: :do_express_checkout_payment],
        [:receiver_username, :mandatory, :string],
        [:token, :mandatory, :string],
        [:payer_id, :mandatory, :string],
        [:order_total, :mandatory, :money],
        [:item_name, :mandatory, :string],
        [:item_quantity, :mandatory, :fixnum],
        [:item_price, :mandatory, :money],
        [:invnum, :mandatory, :string])

      DoExpressCheckoutPaymentResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:order_date, :mandatory, :utc_str_to_time],
        [:payment_status, :mandatory, :string],
        [:pending_reason, :mandatory, :string],
        [:order_id, :mandatory, :string],
        [:order_total, :mandatory, :money],
        [:receiver_id, :mandatory, :string])

      DoAuthorization = EntityUtils.define_builder(
        [:method, const_value: :do_authorization],
        [:receiver_username, :mandatory, :string],
        [:order_id, :mandatory, :string],
        [:authorization_total, :mandatory, :money],
        [:msg_sub_id, transform_with: -> (v) { v.nil? ? SecureRandom.uuid : v }])

      DoAuthorizationResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:authorization_id, :mandatory, :string],
        [:payment_status, :mandatory, :string],
        [:pending_reason, :mandatory, :string],
        [:authorization_total, :mandatory, :money],
        [:authorization_date, :utc_str_to_time],
        [:msg_sub_id, :string])

      DoFullCapture = EntityUtils.define_builder(
        [:method, const_value: :do_capture],
        [:receiver_username, :mandatory, :string],
        [:authorization_id, :mandatory, :string],
        [:payment_total, :mandatory, :money],
        [:invnum, :mandatory, :string])

      DoFullCaptureResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:authorization_id, :mandatory, :string],
        [:payment_id, :mandatory, :string],
        [:payment_status, :mandatory, :string],
        [:pending_reason, :mandatory, :string],
        [:payment_total, :money],
        [:fee_total, :money],
        [:payment_date, :utc_str_to_time])

      DoVoid = EntityUtils.define_builder(
        [:method, const_value: :do_void],
        [:receiver_username, :mandatory, :string],
        [:transaction_id, :mandatory, :string], # To void an order pass order_id. To void an authorization pass authorization_id
        [:note, :string],
        [:msg_sub_id, transform_with: -> (v) { v.nil? ? SecureRandom.uuid : v }])

      DoVoidResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:voided_id, :mandatory, :string],
        [:msg_sub_id, :string])

      RefundTransaction = EntityUtils.define_builder(
        [:method, const_value: :refund_transaction],
        [:receiver_username, :mandatory, :string],
        [:payment_id, :string, :mandatory],
        [:msg_sub_id, transform_with: -> (v ) { v.nil? ? SecureRandom.uuid : v }])

      RefundTransactionResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:refunded_id, :mandatory, :string],
        [:refunded_fee_total, :mandatory, :money],
        [:refunded_net_total, :mandatory, :money],
        [:refunded_gross_total, :mandatory, :money],
        [:refunded_total, :mandatory, :money],
        [:msg_sub_id, :string])

      GetTransactionDetails = EntityUtils.define_builder(
        [:method, const_value: :get_transaction_details],
        [:receiver_username, :mandatory, :string],
        [:transaction_id, :mandatory, :string])

      GetTransactionDetailsResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:transaction_id, :mandatory, :string],
        [:payment_status, :mandatory, :string],
        [:pending_reason, :string],
        [:transaction_total, :money])


      module_function

      def create_setup_billing_agreement(opts); SetupBillingAgreement.call(opts) end
      def create_setup_billing_agreement_response(opts); SetupBillingAgreementResponse.call(opts) end

      def create_create_billing_agreement(opts); CreateBillingAgreement.call(opts) end
      def create_create_billing_agreement_response(opts); CreateBillingAgreementResponse.call(opts) end

      def create_do_reference_transaction(opts); DoReferenceTransaction.call(opts) end
      def create_do_reference_transaction_response(opts); DoReferenceTransactionResponse.call(opts) end

      def create_get_express_checkout_details(opts); GetExpressCheckoutDetails.call(opts) end
      def create_get_express_checkout_details_response(opts); GetExpressCheckoutDetailsResponse.call(opts) end

      def create_set_express_checkout_order(opts); SetExpressCheckoutOrder.call(opts) end
      def create_set_express_checkout_order_response(opts); SetExpressCheckoutOrderResponse.call(opts) end

      def create_do_express_checkout_payment(opts); DoExpressCheckoutPayment.call(opts) end
      def create_do_express_checkout_payment_response(opts); DoExpressCheckoutPaymentResponse.call(opts) end

      def create_do_authorization(opts); DoAuthorization.call(opts) end
      def create_do_authorization_response(opts); DoAuthorizationResponse.call(opts) end

      def create_do_full_capture(opts); DoFullCapture.call(opts) end
      def create_do_full_capture_response(opts); DoFullCaptureResponse.call(opts) end

      def create_do_void(opts); DoVoid.call(opts) end
      def create_do_void_response(opts); DoVoidResponse.call(opts) end

      def create_refund_transaction(opts); RefundTransaction.call(opts) end
      def create_refund_transaction_response(opts); RefundTransactionResponse.call(opts) end

      def create_get_transaction_details(opts); GetTransactionDetails.call(opts) end
      def create_get_transaction_details_response(opts); GetTransactionDetailsResponse.call(opts) end

    end

  end
end
