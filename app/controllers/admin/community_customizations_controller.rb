class Admin::CommunityCustomizationsController < ApplicationController
  before_filter :ensure_is_admin

  def edit_details
    @selected_left_navi_link = "tribe_details"
    # @community_customization is fetched in application_controller
    @community_customizations ||= find_or_initialize_customizations(@current_community.locales)
    all_locales = MarketplaceService::API::Marketplaces.all_locales.map{|l| l[:locale_key]}
    enabled_locale_keys = available_locales.map(&:second)

    custom_translation_in_use = !all_locales.include?(@current_community.locales.first)
    if custom_translation_in_use
      custom_locale_key = @current_community.locales.first
      custom_locale_name = Kassi::Application.config.AVAILABLE_LOCALES.select {|k, v| v == custom_locale_key}.map(&:first).first
      binding.pry
      custom_locale = {key: custom_locale_key, name: custom_locale_name}
    end

    @show_transaction_agreement = TransactionService::API::Api.processes.get(community_id: @current_community.id)
      .maybe
      .map { |data| has_preauthorize_process?(data) }
      .or_else(nil).tap { |p| raise ArgumentError.new("Can not find transaction process: #{opts}") if p.nil? }
    render locals: {
      locale_selection_locals: { all_locales: all_locales, enabled_locale_keys: enabled_locale_keys, custom_locale: custom_locale}
    }
  end

  def update_details
    updates_successful = @current_community.locales.map do |locale|
      permitted_params = [
        :name,
        :slogan,
        :description,
        :search_placeholder,
        :transaction_agreement_label,
        :transaction_agreement_content
      ]
      params.require(:community_customizations).require(locale).permit(*permitted_params)
      locale_params = params[:community_customizations][locale]
      customizations = find_or_initialize_customizations_for_locale(locale)
      customizations.update_attributes(locale_params)
    end

    locales_ok = validate_and_set_locales(params)

    transaction_agreement_checked = Maybe(params)[:community][:transaction_agreement_checkbox].is_some?
    community_update_successful = @current_community.update_attributes(transaction_agreement_in_use: transaction_agreement_checked)

    if updates_successful.all? && community_update_successful && locales_ok
      flash[:notice] = t("layouts.notifications.community_updated")
    else
      flash[:error] = t("layouts.notifications.community_update_failed")
    end

    redirect_to edit_details_admin_community_path(@current_community)
  end

  private

  def validate_and_set_locales(params)
    if !feature_enabled?(:locale_admin)
      true
    else
      enabled_locales = params[:enabled_locales] || []
      custom_locale = params[:custom_locale]
      all_locales = MarketplaceService::API::Marketplaces.all_locales.map{|l| l[:locale_key]}.to_set
      enabled_locales_valid = enabled_locales.map{ |locale| all_locales.include? locale }.all?
      if !enabled_locales_valid || (enabled_locales.blank? && custom_locale.blank?)
        return false
      else
        new_locales = []
        new_locales.push(custom_locale) if custom_locale.present?
        new_locales.concat(enabled_locales)
        MarketplaceService::API::Marketplaces.set_locales(@current_community, new_locales)
      end
    end
  end

  def find_or_initialize_customizations(locales)
    locales.inject({}) do |customizations, locale|
      customizations[locale] = find_or_initialize_customizations_for_locale(locale)
      customizations
    end
  end

  def find_or_initialize_customizations_for_locale(locale)
    @current_community.community_customizations.find_by_locale(locale) || build_customization_with_defaults(locale)
  end

  def build_customization_with_defaults(locale)
    @current_community.community_customizations.build(
      slogan: @current_community.slogan,
      description: @current_community.description,
      search_placeholder: t("homepage.index.what_do_you_need", locale: locale),
      locale: locale
    )
  end

  def has_preauthorize_process?(processes)
    processes.any? { |p| p[:process] == :preauthorize }
  end

end
