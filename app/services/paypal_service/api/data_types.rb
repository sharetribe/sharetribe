module PaypalService::API::DataTypes

  CreatePaymentRequest = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:transaction_id, :mandatory, :fixnum],
    [:item_name, :string],
    [:item_quantity, :fixnum, default: 1],
    [:item_price, :money],
    [:merchant_id, :mandatory, :string],
    [:order_total, :mandatory, :money],
    [:success, :mandatory, :string],
    [:cancel, :mandatory, :string]
  )

  PaymentRequest = EntityUtils.define_builder(
    [:transaction_id, :mandatory, :fixnum],
    [:token, :mandatory, :string],
    [:redirect_url, :mandatory, :string]
  )

  TokenVerificationInfo = EntityUtils.define_builder(
    [:transaction_id, :mandatory, :string]
  )

  Payment = EntityUtils.define_builder(
    [:transaction_id, :mandatory, :fixnum],
    [:payer_id, :mandatory, :string],
    [:receiver_id, :mandatory, :string],
    [:merchant_id, :mandatory, :string],
    [:payment_status, one_of: [:pending, :completed, :refunded]],
    [:pending_reason, :symbol],
    [:order_id, :mandatory, :string],
    [:order_date, :mandatory, :time],
    [:order_total, :mandatory, :money],
    [:authorization_id, :string],
    [:authorization_date, :time],
    [:authorization_expires_date, :time],
    [:authorization_total, :money],
    [:payment_id, :string],
    [:payment_date, :time],
    [:payment_total, :money],
    [:commission_status, one_of: [:not_charged, :charged]],
    [:fee_total, :money])

  AuthorizationInfo = EntityUtils.define_builder(
    [:authorization_total, :mandatory, :money]
  )

  PaymentInfo = EntityUtils.define_builder(
    [:payment_total, :mandatory, :money]
  )

  module_function

  def create_create_payment_request(opts); CreatePaymentRequest.call(opts) end
  def create_payment_request(opts); PaymentRequest.call(opts) end
  def create_token_verification_info(opts); TokenVerificationInfo.call(opts) end
  def create_payment(opts); Payment.call(opts) end
  def create_authorization_info(opts); AuthorizationInfo.call(opts) end
  def create_payment_info(opts); PaymentInfo.call(opts) end

end
