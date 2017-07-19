module TransactionService::Store::PaymentSettings

  PaymentSettingsModel = ::PaymentSettings

  PaymentSettingsUpdate = EntityUtils.define_builder(
    [:active, :to_bool, default: false],
    [:community_id, :mandatory, :fixnum],
    [:payment_gateway, :to_symbol, one_of: [:paypal, :braintree, :checkout, :stripe, :none], default: :none],
    [:payment_process, :to_symbol, one_of: [:preauthorize, :postpay, :free], default: :free],
    [:commission_from_seller, :fixnum],
    [:minimum_price_cents, :fixnum],
    [:minimum_price_currency, :string],
    [:minimum_transaction_fee_cents, :fixnum],
    [:minimum_transaction_fee_currency, :string],
    [:confirmation_after_days, :fixnum, default: 14],
    [:api_client_id, :string],
    [:api_private_key, :string],
    [:api_publishable_key, :string]
  )

  PaymentSettings = EntityUtils.define_builder(
    [:active, :to_bool, default: false],
    [:community_id, :mandatory, :fixnum],
    [:payment_gateway, :to_symbol, one_of: [:paypal, :braintree, :checkout, :stripe, :none], default: :none],
    [:payment_process, :to_symbol, one_of: [:preauthorize, :postpay, :free], default: :free],
    [:commission_from_seller, :fixnum],
    [:minimum_price_cents, :fixnum],
    [:minimum_price_currency, :string],
    [:minimum_transaction_fee_cents, :fixnum],
    [:minimum_transaction_fee_currency, :string],
    [:confirmation_after_days, :fixnum, default: 14],
    [:commission_type, :mandatory, one_of: [:relative, :fixed, :both, :none]],
    [:api_client_id, :string],
    [:api_private_key, :string],
    [:api_publishable_key, :string],
    [:api_visible_private_key, :string],
    [:api_verified, :to_bool],
    [:api_country, :string]
  )

  module_function

  def create(opts)
    settings = HashUtils.compact(PaymentSettingsUpdate.call(opts))
    encrypt_api_keys(settings)
    model = PaymentSettingsModel.create!(settings)
    from_model(model)
  end

  def update(opts)
    settings = HashUtils.compact(PaymentSettingsUpdate.call(opts)).except(:active, :payment_process, :payment_gateway)
    model = find(opts[:community_id], opts[:payment_gateway], opts[:payment_process])
    raise ArgumentError.new("Cannot find settings to update: cid: #{opts[:community_id]}, gateway: #{opts[:payment_gateway]}, process: #{opts[:payment_process]}") if model.nil?

    clean_or_encrypt_api_keys(model, settings)
    model.update_attributes!(settings)
    from_model(model)
  end

  def get(community_id:, payment_gateway:, payment_process:)
    Maybe(find(community_id, payment_gateway, payment_process))
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def get_active_by_gateway(community_id:, payment_gateway:)
    Maybe(PaymentSettingsModel
           .where(community_id: community_id, active: true, payment_gateway: payment_gateway)
           .first)
      .map { |m| from_model(m) }
      .or_else(nil)
  end

  def get_all_active(community_id:)
    PaymentSettingsModel.where(community_id: community_id, active: true).map{|m| from_model(m) }
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

  def api_verified(community_id:, payment_gateway:, payment_process:)
    model = find(community_id, payment_gateway, payment_process)
    raise ArgumentError.new("Cannot find settings to activate: cid: #{community_id}, gateway: #{payment_gateway}, process: #{payment_process}") if model.nil?
    model.update_attributes!(api_verified: true)
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

  API_KEY_FIELDS = %i(api_publishable_key api_private_key)

  def encrypt_api_keys(settings)
    unless API_KEY_FIELDS.all?{|key| settings[key].present?}
      API_KEY_FIELDS.each{|key| settings.delete(key) }
      return
    end
    # store visible hint
    settings[:api_visible_private_key] = settings[:api_private_key].sub(/\A(.{7}).+(.{4})$/, '\1*********************\2')
    settings[:api_private_key] = encrypt_value(settings[:api_private_key])
  end

  def encrypt_value(value)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.key = Digest::SHA256.digest(APP_CONFIG.api_encryption_key)
    iv = cipher.random_iv
    cipher.padding = 0
    cipher.iv = iv
    text = cipher.update(value) + cipher.final
    Base64.strict_encode64(iv + text)
  end

  def decrypt_value(value)
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.decrypt
    cipher.key = Digest::SHA256.digest(APP_CONFIG.api_encryption_key)
    cipher.padding = 0
    plain = Base64.decode64(value)
    cipher.iv = plain.slice!(0,16)
    cipher.update(plain) + cipher.final
  end

  def clean_or_encrypt_api_keys(model, new_settings)
    if model.api_verified?
      API_KEY_FIELDS.each{|key| new_settings.delete(key) }
    else
      encrypt_api_keys(new_settings)
      new_settings[:api_verified] = false
    end
  end

end
