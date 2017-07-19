#
# StripeAccount Store wraps ActiveRecord models and stores accounts to the database.
#
module StripeService::Store::StripeAccount
  StripeAccountModel = ::StripeAccount

  # Stripe is available only in some countries https://stripe.com/global
  COUNTRIES = ["US", "GB", "AT", "BE", "CA", "CH", "DE", "DK", "ES", "FI", "FR", "IE", "IT", "LU", "NL", "NO", "PT", "SE"]

  COUNTRY_NAMES = [
    ["United States", "US"],
    ["United Kingdom", "GB"],
    ["Österreich", "AT"],
    ["België", "BE"],
    ["Canada", "CA"],
    ["Schweiz", "CH"],
    ["Deutschland", "DE"],
    ["Danmark", "DK"],
    ["España", "ES"],
    ["Suomi", "FI"],
    ["France", "FR"],
    ["Ireland", "IE"],
    ["Italia", "IT"],
    ["Luxembourg", "LU"],
    ["Nederland", "NL"],
    ["Norge", "NO"],
    ["Portugal", "PT"],
    ["Sverige", "SE"],
  ]

  StripeAccountCreate = EntityUtils.define_builder(
    [:community_id, :mandatory, :fixnum],
    [:person_id, :optional, :string],

    [:first_name, :string, :mandatory],
    [:last_name, :string, :mandatory],
    [:address_country, :string, :mandatory, one_of: COUNTRIES],
    [:address_city, :string, :mandatory],
    [:address_line1, :string, :mandatory],
    [:address_postal_code, :string, :mandatory],
    [:address_state, :string, :mandatory],
    [:birth_date, :date, :mandatory],
    [:ssn_last_4, :string, :mandatory],
    [:personal_id_number, :string, :optional],

    [:tos_date, :time, :mandatory],
    [:tos_ip, :string, :mandatory],

    [:stripe_seller_id, :string, :mandatory]
  )

  StripeAccountUpdate = EntityUtils.define_builder(
    [:first_name, :string],
    [:last_name, :string],
    [:address_country, :string],
    [:address_city, :string],
    [:address_line1, :string],
    [:address_postal_code, :string],
    [:address_state, :string],
    [:birth_date, :date],
    [:ssn_last_4, :string],
    [:personal_id_number, :string]
  )

  StripeAddressUpdate = EntityUtils.define_builder(
    [:address_city, :string],
    [:address_line1, :string],
    [:address_postal_code, :string],
    [:address_state, :string]
  )

  StripeAccount = EntityUtils.define_builder(
    [:community_id, :fixnum],
    [:person_id, :string],

    [:account_type, :string],

    [:stripe_seller_id, :string],

    [:first_name, :string],
    [:last_name, :string],

    [:address_country, :string],
    [:address_city, :string],
    [:address_line1, :string],
    [:address_postal_code, :string],
    [:address_state, :string],

    [:birth_date, :date],
    [:ssn_last_4, :string],

    [:tos_date, :time],
    [:tos_ip, :string],

    [:charges_enabled, :to_bool],
    [:transfers_enabled, :to_bool],
    [:personal_id_number, :string],
    [:verification_document, :string],

    [:stripe_bank_id, :string],
    [:bank_account_number, :string],
    [:bank_country, :string],
    [:bank_currency, :string],
    [:bank_account_holder_name, :string],
    [:bank_account_holder_type, :string],
    [:bank_routing_number, :string],

    [:stripe_debit_card_id, :string],
    [:stripe_debit_card_source, :string],
    [:stripe_customer_id, :string],
    [:stripe_source_info, :string],
    [:stripe_source_country, :string]
  )

  StripeBankAccount = EntityUtils.define_builder(
    [:stripe_bank_id, :string],
    [:bank_account_number, :string],
    [:bank_country, :string],
    [:bank_currency, :string],
    [:bank_account_holder_name, :string],
    [:bank_account_holder_type, :string],
    [:bank_routing_number, :string]
  )

  module_function

  def create(opts:)
    entity = StripeAccountCreate.call(opts)
    account_model = StripeAccountModel.where(community_id: entity[:community_id], person_id: entity[:person_id]).first
    if account_model
      account_model.update_attributes(entity)
    else
      account_model = StripeAccountModel.create!(entity)
    end
    from_model(account_model)
  end

  def create_customer(opts:)
    account_model = StripeAccountModel.create!(opts.merge({account_type: 'customer'}))
    from_model(account_model)
  end

  def update(community_id:, person_id:, opts:)
    find_params = {
      community_id: community_id,
      person_id: person_id,
    }
    model = StripeAccountModel.where(find_params).first
    entity = StripeAccountUpdate.call(opts)
    model.update_attributes(entity)
    from_model(model)
  end

  def update_address(community_id:, person_id:, opts:)
    find_params = {
      community_id: community_id,
      person_id: person_id,
    }
    model = StripeAccountModel.where(find_params).first
    entity = StripeAddressUpdate.call(opts)
    model.update_attributes(entity)
    from_model(model)
  end


  def update_bank_account(community_id:, person_id:, opts:)
    find_params = {
      community_id: community_id,
      person_id: person_id,
    }
    model = StripeAccountModel.where(find_params).first
    entity = StripeBankAccount.call(opts)
    model.update_attributes(entity)
    from_model(model)
  end

  def update_field(community_id:, person_id:, field:, value:)
    find_params = {
      community_id: community_id,
      person_id: person_id,
    }
    model = StripeAccountModel.where(find_params).first
    model.update_attribute(field, value)
    from_model(model)
  end

  def get(person_id: nil, community_id:)
    from_model(
      StripeAccountModel.where(
        person_id: person_id,
        community_id: community_id
      ).first
    )
  end

  def from_model(model)
    Maybe(model)
      .map { |m| EntityUtils.model_to_hash(m) }
      .map { |hash| StripeAccount.call(hash) }
      .or_else(nil)
  end

end
