module TransactionService::Store::PaymentSettings

  PaymentSettingsModel = ::PaymentSettings

  PaymentSettingsUpdate = EntityUtils.define_builder(
    [:active, :to_bool, default: false],
    [:community_id, :mandatory, :fixnum],
    [:payment_gateway, :to_symbol, one_of: [:paypal, :braintree, :checkout, :none], default: :none],
    [:payment_process, :to_symbol, one_of: [:preauthorize, :postpay, :free], default: :free],
    [:commission_from_seller, :fixnum],
    [:minimum_price_cents, :fixnum],
    [:minimum_transaction_fee_cents, :fixnum],
    [:confirmation_after_days, :fixnum, default: 14]
  )

  PaymentSettings = EntityUtils.define_builder(
    [:active, :to_bool, default: false],
    [:community_id, :mandatory, :fixnum],
    [:payment_gateway, :to_symbol, one_of: [:paypal, :braintree, :checkout, :none], default: :none],
    [:payment_process, :to_symbol, one_of: [:preauthorize, :postpay, :free], default: :free],
    [:commission_from_seller, :fixnum],
    [:minimum_price_cents, :fixnum],
    [:minimum_transaction_fee_cents, :fixnum],
    [:confirmation_after_days, :fixnum, default: 14],
    [:commission_type, :mandatory, one_of: [:relative, :fixed, :both, :none]]
  )

  module_function

  def create(opts)
    settings = HashUtils.compact(PaymentSettingsUpdate.call(opts))
    model = PaymentSettingsModel.create!(settings)
    from_model(model)
  end

  def update(opts)
    settings = HashUtils.compact(PaymentSettingsUpdate.call(opts)).except(:active, :payment_process, :payment_gateway)
    model = find(opts[:community_id], opts[:payment_gateway], opts[:payment_process])
    raise ArgumentError.new("Cannot find settings to update: cid: #{opts[:community_id]}, gateway: #{opts[:payment_gateway]}, process: #{opts[:payment_process]}") if model.nil?

    model.update_attributes!(settings)
    from_model(model)
  end

  def get(community_id:, payment_gateway:, payment_process:)
    Maybe(find(community_id, payment_gateway, payment_process))
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def get_active(community_id:)
    Maybe(PaymentSettingsModel
           .where(community_id: community_id, active: true)
           .first)
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def activate(community_id:, payment_gateway:, payment_process:)
    model = find(community_id, payment_gateway, payment_process)
    raise ArgumentError.new("Cannot find settings to activate: cid: #{community_id}, gateway: #{payment_gateway}, process: #{payment_process}") if model.nil?

    unless model.active
      ActiveRecord::Base.transaction do
        PaymentSettingsModel.where(community_id: community_id, active: true)
          .each { |m| m.update_attributes!(active: false) }
        model.update_attributes!(active: true)
      end
    end

    from_model(model)
  end

  def disable(community_id:, payment_gateway:, payment_process:)
    model = find(community_id, payment_gateway, payment_process)
    raise ArgumentError.new("Cannot find settings to disable: cid: #{community_id}, gateway: #{payment_gateway}, process: #{payment_process}") if model.nil?

    model.update_attributes!(active: false)
    from_model(model)
  end

  ## Privates

  def from_model(model)
    Maybe(model)
      .map { |m| EntityUtils.model_to_hash(m) }
      .map { |hash| PaymentSettings.call(hash.merge({commission_type: commission_type(hash)})) }
      .or_else(nil)
  end

  def commission_type(settings)
    s = Maybe(settings)
    case [s[:commission_from_seller].>(0).or_else(false), s[:minimum_transaction_fee_cents].>(0).or_else(false)]
    when [true, true]
      :both
    when [false, false]
      :none
    when [true, false]
      :relative
    when [false, true]
      :fixed
    end
  end

  def find(community_id, payment_gateway, payment_process)
    PaymentSettingsModel.where(
      community_id: community_id,
      payment_process: payment_process,
      payment_gateway: payment_gateway
    ).first
  end

end
