module Person::PaymentSettingsCommon
  STRIPE_ACCOUNT_FORM_ATTRIBUTES =
    %i[
      first_name
      last_name
      first_name_kana
      last_name_kana
      first_name_kanji
      last_name_kanji
      address_country
      address_city
      address_line1
      address_postal_code
      address_state
      birth_date
      personal_id_number
      address_city
      address_line1
      address_postal_code
      address_state
      document
      additional_document
      document_front
      document_back
      additional_document_front
      additional_document_back
      ssn_last_4
      token
      gender
      phone_number
      address_kana_postal_code
      address_kana_state
      address_kana_city
      address_kana_town
      address_kana_line1
      address_kanji_postal_code
      address_kanji_state
      address_kanji_city
      address_kanji_town
      address_kanji_line1
      id_number
      phone
      email
      url
    ].freeze

  StripeAccountForm = FormUtils.define_form("StripeAccountForm",
                                            *STRIPE_ACCOUNT_FORM_ATTRIBUTES).with_validations do
    validates_inclusion_of :address_country, in: StripeService::Store::StripeAccount::COUNTRIES
    validates_presence_of :address_country
    validates_presence_of :token
  end

  StripeBankForm = FormUtils.define_form("StripeBankForm",
        :bank_country,
        :bank_currency,
        :bank_holder_name,
        :bank_account_number,
        :bank_routing_number,
        :bank_routing_1,
        :bank_routing_2,
        :bank_account_number_common
        ).with_validations do
    validates_presence_of :bank_country,
        :bank_currency,
        :bank_holder_name,
        :bank_account_number
    validates_inclusion_of :bank_country, in: StripeService::Store::StripeAccount::COUNTRIES
    validates_inclusion_of :bank_currency, in: StripeService::Store::StripeAccount::VALID_BANK_CURRENCIES
  end
end
