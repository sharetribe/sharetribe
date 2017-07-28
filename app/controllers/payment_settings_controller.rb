class PaymentSettingsController < ApplicationController
  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_action :ensure_payments_enabled
  before_action :load_stripe_account

  def index
    more_locals = {}
    @extra_forms ||= {}

    if @stripe_enabled
      more_locals.merge!(stripe_index)
    end

    if @paypal_enabled
      more_locals.merge!(paypal_index)
    end

    render 'index', locals: build_view_locals.merge(more_locals).merge(@extra_forms)
  end

  def update
    unless @stripe_enabled
      redirect_to action: :index
    end

    @extra_forms = {}

    if params[:stripe_account_form].present?
      stripe_create_account
    end

    if params[:stripe_bank_form].present?
      stripe_update_bank_account
    end

    if params[:stripe_address_form].present?
      stripe_update_address
    end

    if params[:stripe_verification_form].present?
      stripe_send_verification
    end

    index
  end

  private

  def ensure_payments_enabled
    @paypal_enabled = PaypalHelper.paypal_active?(@current_community.id)
    @stripe_enabled = StripeHelper.stripe_active?(@current_community.id)
    unless @paypal_enabled || @stripe_enabled
      flash[:warning] = t("stripe_accounts.admin_account_not_connected",
                            contact_admin_link: view_context.link_to(
                              t("stripe_accounts.contact_admin_link_text"),
                                new_user_feedback_path)).html_safe # rubocop:disable Rails/OutputSafety
      redirect_to person_settings_path
    end
  end

  def paypal_tx_settings
    Maybe(settings_api.get(community_id: @current_community.id, payment_gateway: :paypal, payment_process: :preauthorize))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else({})
  end

  def stripe_tx_settings
    Maybe(settings_api.get(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else({})
  end

  def build_view_locals
    @selected_left_navi_link = "payments"

    community_currency = @current_community.currency
    payment_settings = @paypal_enabled ? paypal_tx_settings : stripe_tx_settings

    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    if @stripe_account[:stripe_seller_id].present?
      seller_account = stripe_api.get_seller_account(@current_community.id, @stripe_account[:stripe_seller_id])
      need_verification = seller_account && seller_account.managed && seller_account.verification.fields_needed.present?
    else
      need_verification = true
    end

    {
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      commission_from_seller: t("stripe_accounts.commission", commission: payment_settings[:commission_from_seller]),
      minimum_commission: Money.new(payment_settings[:minimum_transaction_fee_cents], community_currency),
      commission_type: payment_settings[:commission_type],
      currency: community_currency,
      stripe_enabled: @stripe_enabled,
      paypal_enabled: @paypal_enabled,
      seller_account: seller_account,
      seller_needs_verification: need_verification
    }
  end

  def stripe_index
    {
      stripe_account: @stripe_account,
      available_countries: STRIPE_COUNTRY_NAMES,
      stripe_account_form: StripeAccountForm.new(@stripe_account),
      stripe_address_form: StripeAddressForm.new(@stripe_account),
      stripe_bank_form: StripeBankForm.new(@stripe_account),
      stripe_verification_form: StripeVerificationForm.new(@stripe_account),
    }
  end

  def paypal_index
    paypal_account = paypal_accounts_api.get(community_id: @current_community.id, person_id: @current_user.id).data || {}
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    {
      next_action: next_action(paypal_account[:state] || ""),
      paypal_account: paypal_account,
      order_permission_action: ask_order_permission_person_paypal_account_path(@current_user),
      billing_agreement_action: ask_billing_agreement_person_paypal_account_path(@current_user),
      paypal_fees_url: PaypalCountryHelper.fee_link(community_country_code),
      create_url: PaypalCountryHelper.create_paypal_account_url(community_country_code),
      upgrade_url: PaypalCountryHelper.upgrade_paypal_account_url(community_country_code),
      receive_funds_info_label_tr_key: PaypalCountryHelper.receive_funds_info_label_tr_key(community_country_code),
      receive_funds_info_tr_key: PaypalCountryHelper.receive_funds_info_tr_key(community_country_code)
    }
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

  def next_action(paypal_account_state)
    if paypal_account_state == :verified
      :none
    elsif paypal_account_state == :connected
      :ask_billing_agreement
    else
      :ask_order_permission
    end
  end

  STRIPE_COUNTRIES = StripeService::Store::StripeAccount::COUNTRIES

  STRIPE_COUNTRY_NAMES = StripeService::Store::StripeAccount::COUNTRY_NAMES

  def load_stripe_account
    @stripe_account = stripe_accounts_api.get(community_id: @current_community.id, person_id: @current_user.id).data || {}
  end

  StripeAccountForm = FormUtils.define_form("StripeAccountForm",
        :first_name,
        :last_name,
        :address_country,
        :address_city,
        :address_line1,
        :address_postal_code,
        :address_state,
        :birth_date,
        :ssn_last_4
        ).with_validations do
    validates_presence_of :first_name, :last_name,
        :address_country, :address_city, :address_line1, :address_postal_code, :address_state,
        :birth_date
    validates_inclusion_of :address_country, in: STRIPE_COUNTRIES
  end

  def stripe_create_account
    return if @stripe_account[:stripe_seller_id].present?
    stripe_account_form = parse_create_params(params[:stripe_account_form])
    @extra_forms[:stripe_account_form] = stripe_account_form
    if stripe_account_form.valid?
      account_attrs = stripe_account_form.to_hash
      account_attrs[:tos_ip] = request.remote_ip
      account_attrs[:tos_date] = Time.zone.now
      result = stripe_accounts_api.create(community_id: @current_community.id, person_id: @current_user.id, body: account_attrs)
      if result[:success]
        load_stripe_account
      else
        flash[:error] = result[:error_msg]
      end
    end
  end

  def parse_create_params(params)
    allowed_params = params.permit(*StripeAccountForm.keys)
    allowed_params[:birth_date] = params[:birth_date].present? ? parse_date(params[:birth_date]) : nil
    StripeAccountForm.new(allowed_params)
  end

  def parse_date(value)
    format = t("datepicker.format").gsub(/([md])[md]+/, '%\1').gsub(/yyyy/, '%Y')
    Date.strptime(value, format) rescue nil # rubocop:disable Style/RescueModifier
  end

  StripeBankForm = FormUtils.define_form("StripeBankForm",
        :bank_country,
        :bank_currency,
        :bank_account_holder_name,
        :bank_account_number,
        :bank_routing_number
        ).with_validations do
    validates_presence_of :bank_country,
        :bank_currency,
        :bank_account_holder_name,
        :bank_account_number
    validates_inclusion_of :bank_country, in: STRIPE_COUNTRIES
  end

  def stripe_update_bank_account
    return false unless @stripe_account[:stripe_seller_id].present?

    bank_params = {
      bank_country: @stripe_account[:address_country],
      bank_currency: @current_community.currency,
      bank_account_holder_name: [@stripe_account[:first_name], @stripe_account[:last_name]].join(" "),
      bank_account_number: params[:stripe_bank_form][:bank_account_number],
      bank_routing_number: params[:stripe_bank_form][:bank_routing_number]
    }

    bank_form = StripeBankForm.new(bank_params)
    @extra_forms[:stripe_bank_form] = bank_form
    has_changes = bank_form.bank_account_number != @stripe_account[:bank_account_number] || bank_form.bank_routing_number != @stripe_account[:bank_routing_number]

    if bank_form.valid? && has_changes
      result = stripe_accounts_api.create_bank_account(community_id: @current_community.id, person_id: @current_user.id, body: bank_form.to_hash)
      if result[:success]
        load_stripe_account
      else
        flash[:error] = result[:error_msg]
      end
    end
  end

  StripeAddressForm = FormUtils.define_form("StripeAddressForm",
        :address_city,
        :address_line1,
        :address_postal_code,
        :address_state).with_validations do
    validates_presence_of :address_city, :address_line1, :address_postal_code
  end

  def stripe_update_address
    return unless @stripe_account[:stripe_seller_id].present?

    address_attrs = params.require(:stripe_address_form).permit(:address_line1, :address_city, :address_state, :address_postal_code)
    @extra_forms[:stripe_address_form] = StripeAddressForm.new(address_attrs)
    result = stripe_accounts_api.update_address(community_id: @current_community.id, person_id: @current_user.id, body: address_attrs)
    if result[:success]
      load_stripe_account
    else
      flash[:error] = result[:error_msg]
    end
  end

  StripeVerificationForm = FormUtils.define_form("StripeVerificationForm",
        :personal_id_number,
        :document).with_validations do
          validates_presence_of :personal_id_number, :document
        end

  def stripe_send_verification
    return unless @stripe_account[:stripe_seller_id].present?

    form = StripeVerificationForm.new(params.require(:stripe_verification_form).permit(:personal_id_number, :document))
    if form.valid?
      result = stripe_accounts_api.send_verification(community_id: @current_community.id, person_id: @current_user.id, personal_id_number: form.personal_id_number, file: form.document.path)
      if result[:success]
        load_stripe_account
      else
        flash[:error] = result[:error_msg]
      end
    end
  end
end
