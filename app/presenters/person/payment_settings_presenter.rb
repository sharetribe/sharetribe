class Person::PaymentSettingsPresenter
  include Person::PaymentSettingsCommon

  private

  attr_reader :service, :person_url

  public

  attr_writer :stripe_account_form, :stripe_bank_form

  def initialize(service:, person_url:)
    @service = service
    @service.presenter = self
    @person_url = person_url
  end

  delegate :community, :params, :person, :person_email, :stripe_error, to: :service, prefix: false

  def reload_from_stripe
    @stripe_account = nil
    @api_seller_account = nil
    api_seller_account
  end

  def reset_stripe
    stripe_account[:stripe_seller_id] = nil
    @stripe_account_ready = false
  end

  def payments_enabled?
    paypal_enabled || stripe_enabled
  end

  def commission_from_seller
    I18n.t("stripe_accounts.commission", commission: payment_settings[:commission_from_seller])
  end

  def minimum_commission
    Money.new(payment_settings[:minimum_transaction_fee_cents], currency)
  end

  def commission_type
    payment_settings[:commission_type]
  end

  def currency
    @currency ||= community.currency
  end

  def stripe_enabled
    @stripe_enabled ||= StripeHelper.community_ready_for_payments?(community.id)
  end

  # seller_account
  def api_seller_account
    return @api_seller_account if @api_seller_account

    @api_seller_account = if stripe_account_ready
                            stripe_api.get_seller_account(community: community.id,
                                                          account_id: stripe_account[:stripe_seller_id])
                          end
  end

  def stripe_account
    @stripe_account ||= stripe_accounts_api.get(community_id: community.id, person_id: person.id).data || {}
  end

  def stripe_account_ready
    @stripe_account_ready ||= stripe_account[:stripe_seller_id].present?
  end

  def stripe_bank_account_ready
    @stripe_bank_account_ready ||= stripe_account[:stripe_bank_id].present?
  end

  def seller_needs_verification
    return @seller_needs_verification if defined?(@seller_needs_verification)

    need_verification = false
    if stripe_account_ready && api_seller_account
      need_verification = [:restricted, :restricted_soon].include?(stripe_account_verification)
    end
    @seller_needs_verification = need_verification
  end

  def seller_required_items
    return @seller_required_items if defined?(@seller_required_items)

    requirements = api_seller_account.requirements
    @seller_required_items = [requirements.try(:currently_due), requirements.try(:past_due), requirements.try(:eventually_due)].compact.flatten.uniq
  end

  def required_individual_id_number?
    @required_individual_id_number ||= seller_required_items.include?("individual.id_number")
  end

  def required_verification_document?
    @required_verification_document ||= seller_required_items.include?("individual.verification.document")
  end

  def required_verification_document_back?
    @required_verification_document_back ||= seller_required_items.include?("individual.verification.document.back")
  end

  def required_verification_additional_document?
    @required_verification_additional_document ||= seller_required_items.include?("individual.verification.additional_document")
  end

  def required_verification_additional_document_back?
    @required_verification_additional_document_back ||= seller_required_items.include?("individual.verification.additional_document.back")
  end

  def capabilities_to_check
    %w[transfers card_payments]
  end

  def has_inactive_capabilities?
    capabilities_to_check.any?{|item| api_seller_account.try(:capabilities).try(:[], item) == 'inactive'}
  end

  def has_pending_capabilities?
    capabilities_to_check.any?{|item| api_seller_account.try(:capabilities).try(:[], item) == 'pending'}
  end

  def stripe_account_verification
    return @stripe_account_verification if defined?(@stripe_account_verification)

    requirements = api_seller_account.requirements
    @stripe_account_verification =
      if requirements.disabled_reason == 'requirements.pending_verification'
        :pending_verification
      elsif requirements.disabled_reason.present?
        :restricted
      elsif requirements.respond_to?(:current_deadline) && requirements.current_deadline.present?
        :restricted_soon
      elsif has_inactive_capabilities?
        :restricted
      elsif has_pending_capabilities?
        :pending_verification
      else
        :verified
      end
  end

  def stripe_account_pending_verification?
    stripe_account_verification == :pending_verification
  end

  def stripe_account_restricted?
    stripe_account_verification == :restricted
  end

  def stripe_account_restricted_soon?
    stripe_account_verification == :restricted_soon
  end

  def stripe_account_verified?
    stripe_account_verification == :verified
  end

  def stripe_seller_account
    return @stripe_seller_account if defined?(@stripe_seller_account)

    @stripe_seller_account = if stripe_account_ready
                               parsed_seller_account
                             else
                               empty_seller_account
                             end
  end

  def stripe_available_countries
    @stripe_available_countries ||= CountryI18nHelper.translate_list(StripeService::Store::StripeAccount::COUNTRIES)
  end

  def stripe_account_form
    @stripe_account_form ||= StripeAccountForm.new(stripe_seller_account.merge(email: person_email))
  end

  def stripe_bank_form
    @stripe_bank_form ||= StripeBankForm.new(stripe_seller_account)
  end

  def stripe_mode
    @stripe_mode ||= stripe_api.charges_mode(community.id)
  end

  def stripe_test_mode
    @stripe_test_mode ||= stripe_api.test_mode?(community.id)
  end

  def stripe_no_bank_account?
    !api_seller_account.present? || !stripe_account[:stripe_bank_id].present?
  end

  def paypal_enabled
    @paypal_enabled ||= PaypalHelper.community_ready_for_payments?(community.id)
  end

  def paypal_commission
    paypal_tx_settings[:commission_from_seller]
  end

  def paypal_account
    @paypal_account ||= paypal_accounts_api.get(community_id: community.id, person_id: person.id).data || {}
  end

  def next_action
    paypal_account_state = paypal_account[:state] || ""
    if paypal_account_state == :verified
      :none
    elsif paypal_account_state == :connected
      :ask_billing_agreement
    else
      :ask_order_permission
    end
  end

  def order_permission_action
    Rails.application.routes.url_helpers.ask_order_permission_person_paypal_account_path(person, locale: I18n.locale)
  end

  def billing_agreement_action
    Rails.application.routes.url_helpers.ask_billing_agreement_person_paypal_account_path(person, locale: I18n.locale)
  end

  def paypal_fees_url
    PaypalCountryHelper.fee_link(community_country_code)
  end

  def create_url
    PaypalCountryHelper.create_paypal_account_url(community_country_code)
  end

  def upgrade_url
    PaypalCountryHelper.upgrade_paypal_account_url(community_country_code)
  end

  def receive_funds_info_label_tr_key
    PaypalCountryHelper.receive_funds_info_label_tr_key(community_country_code)
  end

  def receive_funds_info_tr_key
    PaypalCountryHelper.receive_funds_info_tr_key(community_country_code)
  end

  private

  def parsed_seller_account
    bank_record = api_seller_account.external_accounts.select{|x| x["default_for_currency"] }.first || {}
    bank_number = if bank_record.present?
      [bank_record["country"], bank_record["bank_name"], bank_record["currency"], "****#{bank_record['last4']}"].join(", ").upcase
    end
    entity = api_seller_account.individual
    dob = entity.dob
    url = api_seller_account.try(:business_profile).try(:[], :url)
    url = person_url if url.blank?
    result = {
      first_name: entity.first_name,
      last_name: entity.last_name,
      birth_date: Date.new(dob[:year], dob[:month], dob[:day]),

      bank_number_info: bank_number,
      bank_currency: bank_record ? bank_record["currency"] : nil,
      bank_routing_number: bank_record ? bank_record[:routing_number] : nil,
      email: entity[:email],
      phone: entity[:phone],
      url: url
    }

    if entity.respond_to?(:address)
      result.merge!({
        address_city: entity.address.city,
        address_state: entity.address.state,
        address_country: entity.address.country,
        address_line1: entity.address.line1,
        address_postal_code: entity.address.postal_code
      })
    elsif entity.respond_to?(:address_kana) # supposed to be Japan
      result.merge!({
        address_country: entity.address_kana.country,
        first_name_kana: entity.first_name_kana,
        first_name_kanji: entity.first_name_kanji,
        gender: entity.gender,
        last_name_kana: entity.last_name_kana,
        last_name_kanji: entity.last_name_kanji,
        phone_number: entity[:phone_number],
        address_kana_postal_code: entity.address_kana.postal_code,
        address_kana_state: entity.address_kana.state,
        address_kana_city: entity.address_kana.city,
        address_kana_town: entity.address_kana.town,
        address_kana_line1: entity.address_kana.line1,
        address_kanji_postal_code: entity.address_kanji.postal_code,
        address_kanji_state: entity.address_kanji.state,
        address_kanji_city: entity.address_kanji.city,
        address_kanji_town: entity.address_kanji.town,
        address_kanji_line1: entity.address_kanji.line1,
        phone: entity[:phone]
      })
    end
    mask_us_pr_as_puerto_rico(result)
  end

  def empty_seller_account
    {
      email: person.confirmed_notification_emails.any? ? person.confirmed_notification_email_addresses.first : person.emails.first.try(:address),
      url: person_url
    }
  end

  def payment_settings
    paypal_enabled ? paypal_tx_settings : stripe_tx_settings
  end

  def paypal_tx_settings
    Maybe(settings_api.get(community_id: community.id, payment_gateway: :paypal, payment_process: :preauthorize))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else({})
  end

  def stripe_tx_settings
    Maybe(settings_api.get(community_id: community.id, payment_gateway: :stripe, payment_process: :preauthorize))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else({})
  end

  def stripe_api
    StripeService::API::Api.wrapper
  end

  def stripe_payments_api
    StripeService::API::Api.payments
  end

  def settings_api
    TransactionService::API::Api.settings
  end

  def stripe_accounts_api
    StripeService::API::Api.accounts
  end

  def paypal_accounts_api
    PaypalService::API::Api.accounts
  end

  def mask_us_pr_as_puerto_rico(form_params)
    if form_params[:address_country] == 'US' && form_params[:address_state] == 'PR'
      form_params[:address_country] = 'PR'
    end
    form_params
  end

  def community_country_code
    @community_country_code ||= LocalizationUtils.valid_country_code(community.country)
  end
end
