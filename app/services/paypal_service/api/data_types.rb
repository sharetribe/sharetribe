module PaypalService::API::DataTypes

  CreatePaymentRequest = EntityUtils.define_builder(
    [:transaction_id, :mandatory, :fixnum],
    [:payment_action, :mandatory, one_of: [:order, :authorization]],
    [:item_name, :string],
    [:item_quantity, :fixnum, default: 1],
    [:item_price, :money],
    [:merchant_id, :mandatory, :string],
    [:require_shipping_address, :to_bool, default: false],
    [:shipping_total, :optional, :money],
    [:order_total, :mandatory, :money],
    [:merchant_brand_logo_url, :string, :optional],
    [:success, :mandatory, :string],
    [:cancel, :mandatory, :string]
  )

  # Reponse for get_request_token is a PaypalService::Store::Token::Entity.Token

  PaymentRequest = EntityUtils.define_builder(
    [:transaction_id, :mandatory, :fixnum],
    [:token, :mandatory, :string],
    [:redirect_url, :mandatory, :string]
  )

  Payment = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:transaction_id, :mandatory, :fixnum],
    [:payer_id, :mandatory, :string],
    [:receiver_id, :mandatory, :string],
    [:merchant_id, :mandatory, :string],
    [:payment_status, one_of: [:pending, :completed, :refunded, :voided, :denied, :expired]],
    [:pending_reason, transform_with: -> (v) { (v.is_a? String) ? v.downcase.gsub("-", "").to_sym : v }],
    [:order_id, :string],
    [:order_date, :time],
    [:order_total, :money],
    [:authorization_id, :string],
    [:authorization_date, :time],
    [:authorization_expires_date, :time],
    [:authorization_total, :money],
    [:payment_id, :string],
    [:payment_date, :time],
    [:payment_total, :money],
    [:fee_total, :money],
    [:commission_payment_id, :string],
    [:commission_payment_date, :time],
    [:commission_total, :money],
    [:commission_fee_total, :money],
    [:commission_status, one_of: [:not_charged, :completed, :pending, :seller_is_admin, :below_minimum, :not_applicable, :errored]],
    [:commission_pending_reason, transform_with: -> (v) { (v.is_a? String) ? v.downcase.gsub("-", "").to_sym : v }]
  )

  AuthorizationInfo = EntityUtils.define_builder(
    [:authorization_total, :mandatory, :money]
  )

  PaymentInfo = EntityUtils.define_builder(
    [:payment_total, :mandatory, :money]
  )

  VoidingInfo = EntityUtils.define_builder([:note, :string])

  CommissionInfo = EntityUtils.define_builder(
    [:transaction_id, :mandatory, :fixnum],
    [:commission_total, :mandatory, :money],
    [:payment_name, :mandatory, :string],
    [:payment_desc, :string])

  ProcessStatus = EntityUtils.define_builder(
    [:process_token, :mandatory, :string],
    [:completed, :mandatory, :to_bool],
    [:result])

  CreateAccountRequest = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:person_id, :optional, :string],
    [:country, :mandatory, :string],
    [:callback_url, :mandatory, :string])

  AccountRequest = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:person_id, :optional, :string],
    [:redirect_url, :mandatory, :string],
    [:onboarding_params, :hash])

  AccountPermissionVerificationRequest = EntityUtils.define_builder(
    [:order_permission_verification_code, :string],
    [:onboarding_params, :hash])

  CreateBillingAgreementRequest = EntityUtils.define_builder(
    [:description, :mandatory, :string],
    [:success_url, :mandatory, :string],
    [:cancel_url, :mandatory, :string])

  BillingAgreementRequest = EntityUtils.define_builder(
    [:redirect_url, :mandatory, :string])

  OrderDetails = EntityUtils.define_builder(
    [:status, :string],
    [:city, :string],
    [:country, :string],
    [:country_code, :string],
    [:name, :string],
    [:phone, :string],
    [:postal_code, :string],
    [:state_or_province, :string],
    [:street1, :string],
    [:street2, :string])

  module_function

  def create_create_payment_request(opts); CreatePaymentRequest.call(opts) end
  def create_payment_request(opts); PaymentRequest.call(opts) end
  def create_token_verification_info(opts); TokenVerificationInfo.call(opts) end
  def create_payment(opts); Payment.call(opts) end
  def create_authorization_info(opts); AuthorizationInfo.call(opts) end
  def create_payment_info(opts); PaymentInfo.call(opts) end
  def create_voiding_info(opts); VoidingInfo.call(opts) end
  def create_commission_info(opts); CommissionInfo.call(opts) end
  def create_process_status(opts); ProcessStatus.call(opts) end
  def create_create_account_request(opts); CreateAccountRequest.call(opts) end
  def create_account_request(opts); AccountRequest.call(opts) end
  def create_account_permission_verification_request(opts); AccountPermissionVerificationRequest.call(opts) end
  def create_create_billing_agreement_request(opts); CreateBillingAgreementRequest.call(opts) end
  def create_billing_agreement_request(opts); BillingAgreementRequest.call(opts) end
  def create_order_details(opts); OrderDetails.call(opts) end

end
