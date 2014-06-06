class Admin::CommunityCustomizationsController < ApplicationController
  before_filter :ensure_is_admin

  skip_filter :dashboard_only

  def edit_details
    @selected_left_navi_link = "tribe_details"
    # @community_customization is fetched in application_controller
    @community_customization ||= create_customization_with_defaults
  end

  def update_details
    customizations = if @community_customization
      @community_customization
    else
      create_and_save_customization
    end

    update_successful = customizations.update_attributes(params[:community_customization])

    if update_successful
      flash[:notice] = t("layouts.notifications.community_updated")
    else
      flash.now[:error] = t("layouts.notifications.community_update_failed")
    end

    redirect_to edit_details_admin_community_path(@current_community)
  end

  private

  def create_customization_with_defaults
    CommunityCustomization.new(
      slogan: @current_community.slogan,
      description: @current_community.description,
      search_placeholder: t("homepage.index.what_do_you_need")
    )
  end

  def create_and_save_customization
    customizations = CommunityCustomization.new()
    customizations.community = @current_community
    customizations.locale = I18n.locale
    customizations.save
    customizations
  end

end
