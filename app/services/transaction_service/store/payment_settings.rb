module TransactionService::Store::PaymentSettings

  PaymentSettingsModel = ::PaymentSettings

  PaymentSettings = EntityUtils.define_builder(
    [:active, :to_bool, default: false],
    [:community_id, :mandatory, :fixnum],
    [:payment_gateway, :to_symbol, one_of: [:paypal, :braintree, :checkout, :none], default: :none],
    [:payment_process, :to_symbol, one_of: [:preauthorize, :postpay, :free], default: :free],
    [:commission_from_seller, :fixnum],
    [:minimum_price_cents, :fixnum],
    [:confirmation_after_days, :fixnum, default: 14]
  )

  module_function

  def create(opts)
    settings = HashUtils.compact(PaymentSettings.call(opts))
    model = PaymentSettingsModel.create!(settings)
    from_model(model)
  end

  def get_all(community_id:)
    PaymentSettingsModel
      .where(community_id: community_id)
      .map { |m| from_model(m) }
  end

  def get_active(community_id:)
    Maybe(PaymentSettingsModel
           .where(community_id: community_id, active: true)
           .first)
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  ## Privates

  def from_model(model)
    Maybe(model)
      .map { |m| PaymentSettings.call(EntityUtils.model_to_hash(m)) }
      .or_else(nil)
  end

end
