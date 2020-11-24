class Admin::CommunitiesController < Admin::AdminBaseController
  include CommunitiesHelper

  before_action :ensure_white_label_plan, only: [:create_sender_address]

  def edit_look_and_feel
    @selected_left_navi_link = "tribe_look_and_feel"
    @community = @current_community
    make_onboarding_popup
    render "edit_look_and_feel"
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
      :locale => @current_user.locale,
      :protocol => APP_CONFIG.always_use_ssl.to_s == "true" ? "https://" : "http://"
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
             ses_in_use: ses_in_use,
             show_branding_info: !@current_plan[:features][:whitelabel],
             link_to_sharetribe: "https://www.sharetribe.com/?utm_source=#{@current_community.ident}.sharetribe.com&utm_medium=referral&utm_campaign=nowl-admin-panel"
           }
  end

  def create_sender_address
    user_defined_address = EmailService::API::Api.addresses.get_user_defined(community_id: @current_community.id).data

    if user_defined_address && user_defined_address[:email] == params[:email].to_s.downcase.strip
      EmailService::API::Api.addresses.update(community_id: @current_community.id, id: user_defined_address[:id], name: params[:name])
      flash[:notice] = t("admin.communities.outgoing_email.successfully_saved_name")
      redirect_to action: :edit_welcome_email
      return
    end

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
      render json: {error: res.error_msg }, status: :internal_server_error
    end

  end

  def resend_verification_email
    EmailService::API::Api.addresses.enqueue_verification_request(community_id: @current_community.id, id: params[:address_id])
    render json: {}, status: :ok
  end

  def social_media
    @selected_left_navi_link = "social_media"
    @community = @current_community
    @community.build_social_logo unless @community.social_logo
    find_or_initialize_customizations
    render "social_media", :locals => {
      display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles
    }
  end

  def analytics
    @selected_left_navi_link = "analytics"
    @community = @current_community
    render "analytics", :locals => {
      display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles
    }
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


  def landing_page
    @selected_left_navi_link = "landing_page"

    render :landing_page, locals: { community: @current_community }
  end

  def test_welcome_email
    MailCarrier.deliver_later(PersonMailer.welcome_email(@current_user, @current_community, true, true))
    flash[:notice] = t("layouts.notifications.test_welcome_email_delivered_to", :email => @current_user.confirmed_notification_email_to)
    redirect_to edit_welcome_email_admin_community_path(@current_community)
  end

  def update_look_and_feel
    @community = @current_community
    @selected_left_navi_link = "tribe_look_and_feel"
    analytic = AnalyticService::CommunityLookAndFeel.new(user: @current_user, community: @current_community)

    params[:community][:custom_color1] = nil if params[:community][:custom_color1] == ""
    params[:community][:custom_color2] = nil if params[:community][:custom_color2] == ""
    params[:community][:description_color] = nil if params[:community][:description_color] == ""
    params[:community][:slogan_color] = nil if params[:community][:slogan_color] == ""

    permitted_params = [
      :wide_logo, :logo,:cover_photo, :small_cover_photo, :favicon, :custom_color1,
      :custom_color2, :slogan_color, :description_color, :default_browse_view, :name_display_type,
      attachments_destroyer: []
    ]
    permitted_params << :custom_head_script
    community_params = params.require(:community).permit(*permitted_params)
    analytic.process(@current_community, community_params)

    update(@current_community,
           community_params,
           admin_look_and_feel_edit_path,
           :edit_look_and_feel) { |community|
      flash[:notice] = t("layouts.notifications.images_are_processing") if images_changed?(params)
      analytic.send_properties
      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(community.id)
        .update_from_event(:community_updated, community)
      if state_changed
        record_event(flash, "km_record", {km_event: "Onboarding cover photo uploaded"})
        flash[:show_onboarding_popup] = true
      end
    }
  end

  def update_social_media
    @community = @current_community
    @selected_left_navi_link = "social_media"

    social_media_params = params.require(:community).permit(
      :twitter_handle, :facebook_connect_id, :facebook_connect_secret, :facebook_connect_enabled,
      :google_connect_enabled, :google_connect_id, :google_connect_secret,
      :linkedin_connect_enabled, :linkedin_connect_id, :linkedin_connect_secret,
      social_logo_attributes: [
        :id,
        :image,
        :destroy_image
      ],
      community_customizations_attributes: [
        :id,
        :social_media_title,
        :social_media_description
      ]
    )

    [
      :twitter_handle,
      :facebook_connect_id, :facebook_connect_secret,
      :linkedin_connect_id, :linkedin_connect_secret,
      :google_connect_id, :google_connect_secret
    ].each do |connect_field|
      if social_media_params[connect_field].present?
        social_media_params[connect_field].strip!
      else
        social_media_params[connect_field] = nil
      end
    end

    update(@current_community,
            social_media_params,
            social_media_admin_community_path(@current_community),
            :social_media)
  end

  def update_analytics
    @community = @current_community
    @selected_left_navi_link = "analytics"

    params[:community][:google_analytics_key] = nil if params[:community][:google_analytics_key] == ""
    analytic_params = if APP_CONFIG.admin_enable_tracking_config
                        params.require(:community).permit(:google_analytics_key,
                                                          :end_user_analytics)
                      else
                        params.require(:community).permit(:google_analytics_key)
                      end

    update(@current_community,
            analytic_params,
            analytics_admin_community_path(@current_community),
            :analytics)
  end

  def delete_marketplace
    if can_delete_marketplace?(@current_community.id) && params[:delete_confirmation] == @current_community.ident
      @current_community.update(deleted: true)

      redirect_to Maybe(delete_redirect_url(APP_CONFIG)).or_else(:community_not_found)
    else
      flash[:error] = "Could not delete marketplace."
      redirect_to admin_setting_path
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
    if model.update(params)
      flash[:notice] = t("layouts.notifications.community_updated")
      block.call(model) if block_given? #on success, call optional block
      redirect_to path
    else
      flash.now[:error] = t("layouts.notifications.community_update_failed")
      render action
    end
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
    updates << -> {
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

  def find_or_initialize_customizations
    @current_community.locales.each do |locale|
      next if @current_community.community_customizations.find_by_locale(locale)

      @current_community.community_customizations.create(
        slogan: @current_community.slogan,
        description: @current_community.description,
        search_placeholder: t("homepage.index.what_do_you_need", locale: locale),
        locale: locale
      )
    end
  end
end
