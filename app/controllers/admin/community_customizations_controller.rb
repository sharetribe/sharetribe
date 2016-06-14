class Admin::CommunityCustomizationsController < ApplicationController
  before_filter :ensure_is_admin

  def edit_details
    @selected_left_navi_link = "tribe_details"
    # @community_customization is fetched in application_controller
    @community_customizations ||= find_or_initialize_customizations(@current_community.locales)
    all_locales = MarketplaceService::API::Marketplaces.all_locales.map { |l|
      {locale_key: l[:locale_key], translated_name: t("admin.communities.available_languages.#{l[:locale_key]}")}
    }.sort_by { |l| l[:translated_name] }
    enabled_locale_keys = available_locales.map(&:second)

    @show_transaction_agreement = TransactionService::API::Api.processes.get(community_id: @current_community.id)
      .maybe
      .map { |data| has_preauthorize_process?(data) }
      .or_else(nil).tap { |p| raise ArgumentError.new("Cannot find transaction process: #{opts}") if p.nil? }

    onboarding_popup_locals = OnboardingViewUtils.popup_locals(
      flash[:show_onboarding_popup],
      admin_getting_started_guide_path,
      Admin::OnboardingWizard.new(@current_community.id).setup_status)

    render locals: onboarding_popup_locals.merge({
      locale_selection_locals: { all_locales: all_locales, enabled_locale_keys: enabled_locale_keys, unofficial_locales: unofficial_locales }
    })
  end

  def update_details
    update_results = []

    customizations = @current_community.locales.map do |locale|
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
      update_results.push(customizations.update_attributes(locale_params))
      customizations
    end

    process_locales = unofficial_locales.blank?

    if process_locales
      enabled_locales = params[:enabled_locales]
      all_locales = MarketplaceService::API::Marketplaces.all_locales.map{|l| l[:locale_key]}.to_set
      enabled_locales_valid = enabled_locales.present? && enabled_locales.map{ |locale| all_locales.include? locale }.all?
      if enabled_locales_valid
        MarketplaceService::API::Marketplaces.set_locales(@current_community, enabled_locales)
      end
    end

    transaction_agreement_checked = Maybe(params)[:community][:transaction_agreement_checkbox].is_some?
    update_results.push(@current_community.update_attributes(transaction_agreement_in_use: transaction_agreement_checked))

    if update_results.all? && (!process_locales || enabled_locales_valid)

      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(@current_community.id)
        .update_from_event(:community_customizations_updated, customizations)
      if state_changed
        report_to_gtm({event: "km_record", km_event: "Onboarding slogan/description created"})

        with_feature(:onboarding_redesign_v1) do
          flash[:show_onboarding_popup] = true
        end
      end

      flash[:notice] = t("layouts.notifications.community_updated")
    else
      flash[:error] = t("layouts.notifications.community_update_failed")
    end

    redirect_to admin_details_edit_path
  end

  private

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

  def unofficial_locales
    all_locales = MarketplaceService::API::Marketplaces.all_locales.map{|l| l[:locale_key]}
    @current_community.locales.select { |locale| !all_locales.include?(locale) }
      .map { |unsupported_locale_key|
        unsupported_locale_name = Sharetribe::AVAILABLE_LOCALES.select { |l| l[:ident] == unsupported_locale_key }.map { |l| l[:name] }.first
        {key: unsupported_locale_key, name: unsupported_locale_name}
      }
  end

  def has_preauthorize_process?(processes)
    processes.any? { |p| p[:process] == :preauthorize }
  end

end
