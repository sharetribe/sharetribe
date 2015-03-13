class Admin::CommunityCustomizationsController < ApplicationController
  before_filter :ensure_is_admin

  def edit_details
    @selected_left_navi_link = "tribe_details"
    # @community_customization is fetched in application_controller
    @community_customizations ||= find_or_initialize_customizations(@current_community.locales)
    @show_transaction_agreement = @current_community.transaction_types.any? do |transaction_type|
      # Todo add agreement to TransactionType
      opts = {
        community_id: @current_community.id,
        process_id: transaction_type.transaction_process_id
      }

      process_res = TransactionService::API::Api.processes.get(opts)

      process_res.maybe[:process]
        .map { |process| process == :preauthorize }
        .or_else(nil)
        .tap { |show_agreement|
          raise ArgumentError.new("Can not find transaction process: #{opts}") if show_agreement.nil?
      }
    end
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

    transaction_agreement_checked = Maybe(params)[:community][:transaction_agreement_checkbox].is_some?
    community_update_successful = @current_community.update_attributes(transaction_agreement_in_use: transaction_agreement_checked)

    if updates_successful.all? && community_update_successful
      flash[:notice] = t("layouts.notifications.community_updated")
    else
      flash.now[:error] = t("layouts.notifications.community_update_failed")
    end

    redirect_to edit_details_admin_community_path(@current_community)
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

end
