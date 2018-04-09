class Admin::CommunityCustomizationsController < Admin::AdminBaseController

  def edit_details
    @selected_left_navi_link = "tribe_details"
    # @community_customization is fetched in application_controller
    @community_customizations ||= find_or_initialize_customizations(@current_community.locales)
    all_locales = MarketplaceService.all_locales.map { |l|
      {locale_key: l[:locale_key], translated_name: t("admin.communities.available_languages.#{l[:locale_key]}")}
    }.sort_by { |l| l[:translated_name] }
    enabled_locale_keys = available_locales.map(&:second)

    @show_transaction_agreement = TransactionService::API::Api.processes.get(community_id: @current_community.id)
      .maybe
      .map { |data| has_preauthorize_process?(data) }
      .or_else(nil).tap { |p| raise ArgumentError.new("Cannot find transaction process: #{opts}") if p.nil? }

    make_onboarding_popup
    render locals: {locale_selection_locals: { all_locales: all_locales, enabled_locale_keys: enabled_locale_keys, unofficial_locales: unofficial_locales }}
  end

  def update_details
    update_results = []
    analytic = AnalyticService::CommunityCustomizations.new(user: @current_user, community: @current_community)

    customizations = @current_community.locales.map do |locale|
      permitted_params = [
        :name,
        :slogan,
        :description,
        :search_placeholder,
        :transaction_agreement_label,
        :transaction_agreement_content
      ]
      locale_params = params.require(:community_customizations).require(locale).permit(*permitted_params)
      customizations = find_or_initialize_customizations_for_locale(locale)
      customizations.assign_attributes(locale_params)
      analytic.process(customizations)
      update_results.push(customizations.update_attributes({}))
      customizations
    end

    process_locales = unofficial_locales.blank?

    if process_locales
      enabled_locales = params[:enabled_locales]
      all_locales = MarketplaceService.all_locales.map{|l| l[:locale_key]}.to_set
      enabled_locales_valid = enabled_locales.present? && enabled_locales.map{ |locale| all_locales.include? locale }.all?
      if enabled_locales_valid
        MarketplaceService.set_locales(@current_community, enabled_locales)
      end
    end

    transaction_agreement_checked = Maybe(params)[:community][:transaction_agreement_checkbox].is_some?
    update_results.push(@current_community.update_attributes(transaction_agreement_in_use: transaction_agreement_checked))

    analytic.send_properties
    if update_results.all? && (!process_locales || enabled_locales_valid)

      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(@current_community.id)
        .update_from_event(:community_customizations_updated, customizations)
      if state_changed
        record_event(flash, "km_record", {km_event: "Onboarding slogan/description created"})

        flash[:show_onboarding_popup] = true
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
    all_locales = MarketplaceService.all_locales.map{|l| l[:locale_key]}
    @current_community.locales.select { |locale| !all_locales.include?(locale) }
      .map { |unsupported_locale_key|
        unsupported_locale_name = Sharetribe::AVAILABLE_LOCALES.select { |l| l[:ident] == unsupported_locale_key }.map { |l| l[:name] }.first
        {key: unsupported_locale_key, name: unsupported_locale_name}
      }
  end

  def has_preauthorize_process?(processes)
    processes.any? { |p| p.process == :preauthorize }
  end
end
