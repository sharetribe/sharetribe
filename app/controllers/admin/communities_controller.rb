class Admin::CommunitiesController < Admin::AdminBaseController
  include CommunitiesHelper

  before_action :ensure_white_label_plan, only: [:create_sender_address]

  def edit_look_and_feel
    @selected_left_navi_link = "tribe_look_and_feel"
    @community = @current_community

    onboarding_popup_locals = OnboardingViewUtils.popup_locals(
      flash[:show_onboarding_popup],
      admin_getting_started_guide_path,
      Admin::OnboardingWizard.new(@current_community.id).setup_status)

    render "edit_look_and_feel", locals: onboarding_popup_locals
  end

  def edit_text_instructions
    @selected_left_navi_link = "text_instructions"
    @community = @current_community
  end

  def edit_welcome_email
    @selected_left_navi_link = "welcome_email"
    @community = @current_community
    @recipient = @current_user
    @url_params = {
      :host => @current_community.full_domain,
      :ref => "welcome_email",
      :locale => @current_user.locale
    }

    sender_address = EmailService::API::Api.addresses.get_sender(community_id: @current_community.id).data
    user_defined_address = EmailService::API::Api.addresses.get_user_defined(community_id: @current_community.id).data
    ses_in_use = EmailService::API::Api.ses_client.present?

    enqueue_status_sync!(user_defined_address)

    render "edit_welcome_email", locals: {
             status_check_url: check_email_status_admin_community_path,
             resend_url: Maybe(user_defined_address).map { |address| resend_verification_email_admin_community_path(address_id: address[:id]) }.or_else(nil),
             support_email: APP_CONFIG.support_email,
             sender_address: sender_address,
             user_defined_address: user_defined_address,
             post_sender_address_url: create_sender_address_admin_community_path,
             can_set_sender_address: can_set_sender_address(@current_plan),
             knowledge_base_url: APP_CONFIG.knowledge_base_url,
             ses_in_use: ses_in_use,
             show_branding_info: !@current_plan[:features][:whitelabel],
             link_to_sharetribe: "https://www.sharetribe.com/?utm_source=#{@current_community.ident}.sharetribe.com&utm_medium=referral&utm_campaign=nowl-admin-panel"
           }
  end

  def create_sender_address
    res = EmailService::API::Api.addresses.create(
      community_id: @current_community.id,
      address: {
        name: params[:name],
        email: params[:email]
      })

    if res.success
      flash[:notice] =
        t("admin.communities.outgoing_email.successfully_saved")

      redirect_to action: :edit_welcome_email
    else
      error_message =
        case Maybe(res.data)[:error_code]
        when Some(:invalid_email)
          t("admin.communities.outgoing_email.invalid_email_error", email: res.data[:email])
        when Some(:invalid_domain)
          kb_link = view_context.link_to(t("admin.communities.outgoing_email.invalid_email_domain_read_more_link"), "#{APP_CONFIG.knowledge_base_url}/configuration-and-how-to/how-to-define-your-own-address-as-the-sender-of-all-outgoing-emails", class: "flash-error-link") # rubocop:disable Metrics/LineLength
          t("admin.communities.outgoing_email.invalid_email_domain", email: res.data[:email], domain: res.data[:domain], invalid_email_domain_read_more_link: kb_link).html_safe
        else
          t("admin.communities.outgoing_email.unknown_error")
        end

      flash[:error] = error_message
      redirect_to action: :edit_welcome_email
    end

  end

  def check_email_status
    res = EmailService::API::Api.addresses.get_user_defined(community_id: @current_community.id)

    if res.success
      address = res.data

      if params[:sync]
        enqueue_status_sync!(address)
      end

      render json: HashUtils.camelize_keys(address.merge(translated_verification_sent_time_ago: time_ago(address[:verification_requested_at])))
    else
      render json: {error: res.error_msg }, status: 500
    end

  end

  def resend_verification_email
    EmailService::API::Api.addresses.enqueue_verification_request(community_id: @current_community.id, id: params[:address_id])
    render json: {}, status: 200
  end

  def social_media
    @selected_left_navi_link = "social_media"
    @community = @current_community
    render "social_media", :locals => {
      display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles,
      knowledge_base_url: APP_CONFIG.knowledge_base_url}
  end

  def analytics
    @selected_left_navi_link = "analytics"
    @community = @current_community
    render "analytics", :locals => {
      display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles,
      knowledge_base_url: APP_CONFIG.knowledge_base_url}
  end

  def new_layout
    @selected_left_navi_link = "new_layout"

    features = NewLayoutViewUtils.features(@current_community.id,
                                           @current_user.id,
                                           @current_community.private,
                                           CustomLandingPage::LandingPageStore.enabled?(@current_community.id))

    render :new_layout, locals: { community: @current_community,
                                  feature_rels: NewLayoutViewUtils::FEATURE_RELS,
                                  features: features }
  end

  def update_new_layout
    h_params = params.to_unsafe_hash
    @community = @current_community
    enabled_for_user = Maybe(h_params[:enabled_for_user]).map { |f| NewLayoutViewUtils.enabled_features(f) }.or_else([])
    disabled_for_user = NewLayoutViewUtils.resolve_disabled(enabled_for_user)

    enabled_for_community = Maybe(h_params[:enabled_for_community]).map { |f| NewLayoutViewUtils.enabled_features(f) }.or_else([])
    disabled_for_community = NewLayoutViewUtils.resolve_disabled(enabled_for_community)

    response = update_feature_flags(community_id: @current_community.id, person_id: @current_user.id,
                                    user_enabled: enabled_for_user, user_disabled: disabled_for_user,
                                    community_enabled: enabled_for_community, community_disabled: disabled_for_community)

    if Maybe(response)[:success].or_else(false)
      flash[:notice] = t("layouts.notifications.community_updated")
    else
      flash[:error] = t("layouts.notifications.community_update_failed")
    end
    redirect_to admin_new_layout_path
  end

  def topbar
    @selected_left_navi_link = "topbar"

    if FeatureFlagHelper.feature_enabled?(:topbar_v1) || CustomLandingPage::LandingPageStore.enabled?(@current_community.id)
      limit_priority_links = MarketplaceService::API::Api.configurations.get(community_id: @current_community.id).data[:limit_priority_links]
      all = view_context.t("admin.communities.menu_links.all")
      limit_priority_links_options = (0..5).to_a.map {|o| [o, o]}.concat([[all, -1]])
      limit_priority_links_selected = Maybe(limit_priority_links).or_else(-1)
    end

    # Limits are by default nil
    render :topbar, locals: {
             community: @current_community,
             limit_priority_links: limit_priority_links,
             limit_priority_links_options: limit_priority_links_options,
             limit_priority_links_selected: limit_priority_links_selected
           }
  end

  def update_topbar
    @community = @current_community
    h_params = params.to_unsafe_hash

    menu_links_params = Maybe(params)[:menu_links].permit!.or_else({menu_link_attributes: {}})

    if FeatureFlagHelper.feature_enabled?(:topbar_v1) || CustomLandingPage::LandingPageStore.enabled?(@current_community.id)
      limit_priority_links = params[:limit_priority_links].to_i
      MarketplaceService::API::Api.configurations.update({
        community_id: @current_community.id,
        configurations: {
          limit_priority_links: limit_priority_links
        }
      })
    end

    translations = h_params[:post_new_listing_button].map{ |k, v| {locale: k, translation: v}}

    if translations.any?{ |t| t[:translation].blank? }
      flash[:error] = t("admin.communities.topbar.invalid_post_listing_button_label")
      redirect_to admin_topbar_edit_path and return
    end

    translations_group = [{
      translation_key: "homepage.index.post_new_listing",
      translations: translations
    }]
    TranslationService::API::Api.translations.create(@community.id, translations_group)

    update(@community,
            menu_links_params,
            admin_topbar_edit_path,
            :topbar)
  end

  def landing_page
    @selected_left_navi_link = "landing_page"

    render :landing_page, locals: { community: @current_community }
  end

  def test_welcome_email
    MailCarrier.deliver_later(PersonMailer.welcome_email(@current_user, @current_community, true, true))
    flash[:notice] = t("layouts.notifications.test_welcome_email_delivered_to", :email => @current_user.confirmed_notification_email_to)
    redirect_to edit_welcome_email_admin_community_path(@current_community)
  end

  def settings
    @selected_left_navi_link = "admin_settings"

    # When feature flag is removed, make this pretty
    if(FeatureFlagHelper.location_search_available)
      marketplace_configurations = MarketplaceService::API::Api.configurations.get(community_id: @current_community.id).data

      keyword_and_location =
        if FeatureFlagService::API::Api.features.get_for_community(community_id: @current_community.id).data[:features].include?(:topbar_v1)
          [:keyword_and_location]
        else
          []
        end

      main_search_select_options = [:keyword, :location].concat(keyword_and_location)
        .map { |type|
          [SettingsViewUtils.search_type_translation(type), type]
        }

      distance_unit_select_options = [
          [SettingsViewUtils.distance_unit_translation(:km), :metric],
          [SettingsViewUtils.distance_unit_translation(:miles), :imperial]
      ]

      render :settings, locals: {
        delete_redirect_url: delete_redirect_url(APP_CONFIG),
        delete_confirmation: @current_community.ident,
        can_delete_marketplace: can_delete_marketplace?(@current_community.id),
        main_search: marketplace_configurations[:main_search],
        main_search_select_options: main_search_select_options,
        distance_unit: marketplace_configurations[:distance_unit],
        distance_unit_select_options: distance_unit_select_options,
        limit_distance: marketplace_configurations[:limit_search_distance]
      }
    else
      render :settings, locals: {
        delete_redirect_url: delete_redirect_url(APP_CONFIG),
        delete_confirmation: @current_community.ident,
        can_delete_marketplace: can_delete_marketplace?(@current_community.id)
      }
    end
  end

  def update_look_and_feel
    @community = @current_community
    @selected_left_navi_link = "tribe_look_and_feel"

    params[:community][:custom_color1] = nil if params[:community][:custom_color1] == ""
    params[:community][:custom_color2] = nil if params[:community][:custom_color2] == ""
    params[:community][:description_color] = nil if params[:community][:description_color] == ""
    params[:community][:slogan_color] = nil if params[:community][:slogan_color] == ""

    permitted_params = [
      :wide_logo, :logo,:cover_photo, :small_cover_photo, :favicon, :custom_color1,
      :custom_color2, :slogan_color, :description_color, :default_browse_view, :name_display_type
    ]
    permitted_params << :custom_head_script
    community_params = params.require(:community).permit(*permitted_params)

    update(@current_community,
           community_params,
           admin_look_and_feel_edit_path,
           :edit_look_and_feel) { |community|
      flash[:notice] = t("layouts.notifications.images_are_processing") if images_changed?(params)
      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(community.id)
        .update_from_event(:community_updated, community)
      if state_changed
        report_to_gtm({event: "km_record", km_event: "Onboarding cover photo uploaded"})

        flash[:show_onboarding_popup] = true
      end
    }
  end

  def update_social_media
    @community = @current_community
    @selected_left_navi_link = "social_media"

    [:twitter_handle,
     :facebook_connect_id,
     :facebook_connect_secret].each do |param|
      params[:community][param] = nil if params[:community][param] == ""
    end

    social_media_params = params.require(:community).permit(
      :twitter_handle, :facebook_connect_id, :facebook_connect_secret
    )

    update(@current_community,
            social_media_params,
            social_media_admin_community_path(@current_community),
            :social_media)
  end

  def update_analytics
    @community = @current_community
    @selected_left_navi_link = "analytics"

    params[:community][:google_analytics_key] = nil if params[:community][:google_analytics_key] == ""
    analytic_params = params.require(:community).permit(:google_analytics_key)

    update(@current_community,
            analytic_params,
            analytics_admin_community_path(@current_community),
            :analytics)
  end

  def update_settings
    @selected_left_navi_link = "settings"

    permitted_params = [
      :join_with_invite_only,
      :users_can_invite_new_users,
      :private,
      :require_verification_to_post_listings,
      :show_category_in_listing_list,
      :show_listing_publishing_date,
      :listing_comments_in_use,
      :automatic_confirmation_after_days,
      :automatic_newsletters,
      :default_min_days_between_community_updates,
      :email_admins_about_new_members
    ]
    settings_params = params.require(:community).permit(*permitted_params)

    maybe_update_payment_settings(@current_community.id, params[:community][:automatic_confirmation_after_days])

    if(FeatureFlagHelper.location_search_available)
      MarketplaceService::API::Api.configurations.update({
        community_id: @current_community.id,
        configurations: {
          main_search: params[:main_search],
          distance_unit: params[:distance_unit],
          limit_search_distance: params[:limit_distance].present?
        }
      })
    end

    update(@current_community,
            settings_params,
            admin_settings_path,
            :settings)
  end

  def delete_marketplace
    if can_delete_marketplace?(@current_community.id) && params[:delete_confirmation] == @current_community.ident
      @current_community.update_attributes(deleted: true)

      redirect_to Maybe(delete_redirect_url(APP_CONFIG)).or_else(:community_not_found)
    else
      flash[:error] = "Could not delete marketplace."
      redirect_to action: :settings
    end

  end

  private

  def enqueue_status_sync!(address)
    Maybe(address)
      .reject { |addr| addr[:verification_status] == :verified }
      .each { |addr|
      EmailService::API::Api.addresses.enqueue_status_sync(
        community_id: addr[:community_id],
        id: addr[:id])
    }
  end

  def images_changed?(params)
    !params[:community][:cover_photo].nil? ||
    !params[:community][:small_cover_photo].nil? ||
    !params[:community][:wide_logo].nil? ||
    !params[:community][:logo].nil? ||
    !params[:community][:favicon].nil?
  end

  def update(model, params, path, action, &block)
    if model.update_attributes(params)
      flash[:notice] = t("layouts.notifications.community_updated")
      block.call(model) if block_given? #on success, call optional block
      redirect_to path
    else
      flash.now[:error] = t("layouts.notifications.community_update_failed")
      render action
    end
  end

  # TODO The home of this setting should be in payment settings but
  # those are only used with paypal for now. During the transition
  # period we simply mirror community setting to payment settings in
  # case of paypal.
  def maybe_update_payment_settings(community_id, automatic_confirmation_after_days)
    return unless automatic_confirmation_after_days

    p_set = Maybe(payment_settings_api.get(
                   community_id: community_id,
                   payment_gateway: :paypal,
                   payment_process: :preauthorize))
            .map {|res| res[:success] ? res[:data] : nil}
            .or_else(nil)

    payment_settings_api.update(p_set.merge({confirmation_after_days: automatic_confirmation_after_days.to_i})) if p_set

    p_set = Maybe(payment_settings_api.get(
                   community_id: community_id,
                   payment_gateway: :stripe,
                   payment_process: :preauthorize))
            .map {|res| res[:success] ? res[:data] : nil}
            .or_else(nil)

    payment_settings_api.update(p_set.merge({confirmation_after_days: automatic_confirmation_after_days.to_i})) if p_set
  end

  def payment_settings_api
    TransactionService::API::Api.settings
  end

  def delete_redirect_url(configs)
    Maybe(configs).community_not_found_redirect.or_else(nil)
  end

  def can_delete_marketplace?(community_id)
    PlanService::API::Api.plans.get_current(community_id: community_id).data[:features][:deletable]
  end

  def can_set_sender_address(plan)
    plan[:features][:admin_email]
  end

  def ensure_white_label_plan
    unless can_set_sender_address(@current_plan)
      flash[:error] = "Not available for your plan" # User shouldn't
                                                    # normally come
                                                    # here because
                                                    # access is
                                                    # restricted in
                                                    # front-end. Thus,
                                                    # no need to
                                                    # translate.

      redirect_to action: :edit_welcome_email
    end
  end

  def update_feature_flags(community_id:, person_id:, user_enabled:, user_disabled:, community_enabled:, community_disabled:)
    updates = []
    updates << ->() {
      FeatureFlagService::API::Api.features.enable(community_id: community_id, person_id: person_id, features: user_enabled)
    } unless user_enabled.blank?
    updates << ->(*) {
      FeatureFlagService::API::Api.features.disable(community_id: @current_community.id, person_id: @current_user.id, features: user_disabled)
    } unless user_disabled.blank?
    updates << ->(*) {
      FeatureFlagService::API::Api.features.enable(community_id: @current_community.id, features: community_enabled)
    } unless community_enabled.blank?
    updates << ->(*) {
      FeatureFlagService::API::Api.features.disable(community_id: @current_community.id, features: community_disabled)
    } unless community_disabled.blank?

    Result.all(*updates)
  end
end
