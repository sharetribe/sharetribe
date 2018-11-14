class Admin::Communities::TopbarController < Admin::AdminBaseController
  def edit
    @selected_left_navi_link = "topbar"

    if FeatureFlagHelper.feature_enabled?(:topbar_v1) || CustomLandingPage::LandingPageStore.enabled?(@current_community.id)
      limit_priority_links = @current_community.configuration&.limit_priority_links
      all = view_context.t("admin.communities.menu_links.all")
      limit_priority_links_options = (0..5).to_a.map {|o| [o, o]}.concat([[all, -1]])
      limit_priority_links_selected = Maybe(limit_priority_links).or_else(-1)
    end

    # Limits are by default nil
    render :edit, locals: {
             community: @current_community,
             limit_priority_links: limit_priority_links,
             limit_priority_links_options: limit_priority_links_options,
             limit_priority_links_selected: limit_priority_links_selected
           }
  end

  def update
    menu_links_params = Maybe(params)[:menu_links].permit!.or_else({menu_link_attributes: {}})

    if FeatureFlagHelper.feature_enabled?(:topbar_v1) || CustomLandingPage::LandingPageStore.enabled?(@current_community.id)
      limit_priority_links = params[:limit_priority_links].to_i
      @current_community.configuration.update(limit_priority_links: limit_priority_links)
    end

    translations = params.to_unsafe_hash[:post_new_listing_button].map{ |k, v| {locale: k, translation: v}}

    if translations.any?{ |t| t[:translation].blank? }
      flash[:error] = t("admin.communities.topbar.invalid_post_listing_button_label")
      redirect_to admin_topbar_edit_path and return
    end

    translations_group = [{
      translation_key: "homepage.index.post_new_listing",
      translations: translations
    }]
    TranslationService::API::Api.translations.create(@current_community.id, translations_group)

    if @current_community.update_attributes(menu_links_params)
      flash[:notice] = t("layouts.notifications.community_updated")
      redirect_to admin_topbar_edit_path
    else
      flash.now[:error] = t("layouts.notifications.community_update_failed")
      render :edit
    end
  end
end
