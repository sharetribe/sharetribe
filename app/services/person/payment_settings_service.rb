class Person::PaymentSettingsService
  include Person::PaymentSettingsCommon
  attr_reader :community, :params, :person, :stripe_error, :stripe_error_message
  attr_accessor :presenter

  def initialize(community:, params:, person:)
    @community = community
    @params = params
    @person = person
    @stripe_error = nil
    @stripe_error_message = nil
  end

  delegate :stripe_account_ready, to: :presenter, prefix: false

  def create
    stripe_create_account
    stripe_update_bank_account
    # If we can't create both account and link external bank account, ignore this partial record, and not store in our DB
    if stripe_error && stripe_account_ready
      stripe_accounts_api.destroy(community_id: community.id, person_id: person.id)
      presenter.reset_stripe
    end
  end

  def update
    stripe_update_account
    stripe_update_bank_account
  end

  def person_email
    @person_email ||= person.confirmed_notification_email_addresses.first || person.primary_email.try(:address)
  end

  private

  def stripe_create_account
    return if stripe_account_ready

    stripe_account_form = StripeAccountForm.new(parse_create_params(params[:stripe_account_form]))
    presenter.stripe_account_form = stripe_account_form
    if stripe_account_form.valid?
      account_attrs = stripe_account_form.to_hash
      account_attrs[:email] =  person.confirmed_notification_email_addresses.first || person.primary_email.try(:address)
      result = stripe_accounts_api.create(community_id: community.id, person_id: person.id, body: account_attrs)
      if result[:success]
        presenter.reload_from_stripe
      else
        @stripe_error = true
        @stripe_error_message = result[:error_msg]
      end
    end
  end

  def stripe_update_account
    return unless stripe_account_ready

    address_attrs = stripe_account_form_permitted_params.to_hash.deep_symbolize_keys!
    presenter.stripe_account_form = StripeAccountForm.new(stripe_account_form_permitted_params)
    address_attrs[:email] = person_email
    result = stripe_accounts_api.update_account(community_id: community.id, person_id: person.id, attrs: address_attrs)
    if result[:success]
      presenter.reload_from_stripe
    else
      @stripe_error_message = result[:error_msg]
    end
  end

  def parse_create_params(params)
    allowed_params = mask_puerto_rico_as_us_pr(params.permit(*StripeAccountForm.keys).dup)
    allowed_params[:birth_date] = params["birth_date(1i)"].present? ? parse_date(params) : nil
    allowed_params
  end

  def parse_date(params)
    Date.new params["birth_date(1i)"].to_i, params["birth_date(2i)"].to_i, params["birth_date(3i)"].to_i
  end

  def stripe_account_form_permitted_params
    address_attrs = params.require(:stripe_account_form).dup.permit(
      STRIPE_ACCOUNT_FORM_ATTRIBUTES + ['birth_date(1i)', 'birth_date(2i)', 'birth_date(3i)']
    )
    address_attrs[:birth_date] = address_attrs['birth_date(1i)'].present? ? parse_date(address_attrs) : nil
    address_attrs = mask_puerto_rico_as_us_pr(address_attrs)
  end

  def mask_puerto_rico_as_us_pr(form_params)
    if form_params[:address_country] == 'PR'
      form_params[:address_country] = 'US'
      form_params[:address_state] = 'PR'
    end
    form_params
  end

  def stripe_update_bank_account
    bank_params = StripeParseBankParams.new(parsed_seller_account: presenter.stripe_seller_account, params: params).parse
    bank_form = StripeBankForm.new(bank_params)
    presenter.stripe_bank_form = bank_form
    return if !stripe_account_ready || params[:stripe_bank_form].blank?

    if bank_form.valid? && bank_form.bank_account_number !~ /\*/
      result = stripe_accounts_api.create_bank_account(community_id: community.id, person_id: person.id, body: bank_form.to_hash)
      if result[:success]
        presenter.reload_from_stripe
      else
        @stripe_error = true
        @stripe_error_message = result[:error_msg]
        presenter.stripe_seller_account[:bank_number_info] = (params[:stripe_bank_form].try(:[], :bank_account_number_common) ||
                                                     params[:stripe_bank_form].try(:[], :bank_account_number))
      end
    else
      @stripe_error_message = bank_form.errors.messages.flatten.join(' ')
    end
  end

  class StripeParseBankParams
    attr_reader :bank_country, :bank_currency, :form_params, :parsed_seller_account
    def initialize(parsed_seller_account:, params:)
      @parsed_seller_account = parsed_seller_account
      @bank_country = parsed_seller_account[:address_country]
      if @bank_country == 'PR'
        @bank_country = 'US'
      end
      @bank_currency = TransactionService::AvailableCurrencies::COUNTRY_CURRENCIES[@bank_country]
      @form_params = params[:stripe_bank_form]
    end

    def parse
      result = {
        bank_country: bank_country,
        bank_currency: bank_currency,
        bank_holder_name: parse_holder_name
      }
      if form_params.present?
        result.merge!({
          bank_account_number: parse_bank_account_number,
          bank_routing_number: parse_bank_routing_number,
          bank_routing_1: form_params[:bank_routing_1],
          bank_routing_2: form_params[:bank_routing_2]
        })
      end
      result
    end

    def parse_bank_routing_number
      if bank_country == 'NZ'
        bank_number, bank_branch, = form_params[:bank_account_number_common].split('-')
        "#{bank_number}#{bank_branch}"
      elsif bank_country == 'JP'
        [form_params[:bank_routing_1], form_params[:bank_routing_2]].join('')
      elsif form_params[:bank_routing_1].present?
        [form_params[:bank_routing_1], form_params[:bank_routing_2]].join("-")
      else
        form_params[:bank_routing_number]
      end
    end

    def parse_bank_account_number
      if bank_country == 'NZ'
        _, _, account, sufix = form_params[:bank_account_number_common].split('-')
        "#{account}#{sufix}"
      else
        form_params[:bank_account_number]
      end
    end

    def parse_holder_name
      if bank_country == 'JP'
        [parsed_seller_account[:first_name_kana], parsed_seller_account[:last_name_kana]].join(" ")
      else
        [parsed_seller_account[:first_name], parsed_seller_account[:last_name]].join(" ")
      end
    end
  end

  def stripe_accounts_api
    StripeService::API::Api.accounts
  end
end
