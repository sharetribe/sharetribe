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
        [:order_total, :mandatory, :money])

      DoReferenceTransactionResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:billing_agreement_id, :mandatory, :string],
        [:transaction_id, :mandatory, :string],
        [:order_total, :mandatory, :money],
        [:fee, :mandatory, :money],
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
        [:order_total, :mandatory, :money],
        [:note_to_seller, :string])

      SetExpressCheckoutOrder = EntityUtils.define_builder(
        [:method, const_value: :set_express_checkout_order],
        [:description, :mandatory, :string],
        [:receiver_username, :mandatory, :string],
        [:order_total, :mandatory, :money],
        [:success, :mandatory, :string],
        [:cancel, :mandatory, :string])

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
        [:order_total, :mandatory, :money])

      DoExpressCheckoutPaymentResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:payment_date, :mandatory, :str_to_time],
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
        [:msg_sub_id, :string])

      DoFullCapture = EntityUtils.define_builder(
        [:method, const_value: :do_capture],
        [:receiver_username, :mandatory, :string],
        [:authorization_id, :mandatory, :string],
        [:payment_total, :mandatory, :money])

      DoFullCaptureResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:authorization_id, :mandatory, :string],
        [:payment_id, :mandatory, :string],
        [:payment_status, :mandatory, :string],
        [:pending_reason, :mandatory, :string],
        [:payment_total, :mandatory, :money],
        [:fee_total, :mandatory, :money],
        [:payment_date, :mandatory, :str_to_time])

      DoVoid = EntityUtils.define_builder(
        [:method, const_value: :do_void],
        [:receiver_username, :mandatory, :string],
        [:authorization_id, :string], # Must have either authorization_id or order_id
        [:order_id, :string],
        [:note, :string],
        [:msg_sub_id, transform_with: -> (v) { v.nil? ? SecureRandom.uuid : v }])

      DoVoidResponse = EntityUtils.define_builder(
        [:success, const_value: true],
        [:voided_id, :mandatory, :string],
        [:msg_sub_id, :string])


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

    end

  end
end
