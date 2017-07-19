require 'will_paginate/array'

class ApplicationController < ActionController::Base

  module DefaultURLOptions
    # Adds locale to all links
    def default_url_options
      { :locale => I18n.locale }
    end
  end

  include ApplicationHelper
  include IconHelper
  include DefaultURLOptions
  protect_from_forgery
  layout 'application'

  before_action :check_http_auth,
    :check_auth_token,
    :fetch_community,
    :fetch_community_plan_expiration_status,
    :perform_redirect,
    :fetch_logged_in_user,
    :initialize_feature_flags,
    :save_current_host_with_port,
    :fetch_community_membership,
    :redirect_removed_locale,
    :set_locale,
    :redirect_locale_param,
    :fetch_community_admin_status,
    :warn_about_missing_payment_info,
    :set_homepage_path,
    :maintenance_warning,
    :cannot_access_if_banned,
    :cannot_access_without_confirmation,
    :ensure_consent_given,
    :ensure_user_belongs_to_community,
    :set_display_expiration_notice

  # This updates translation files from WTI on every page load. Only useful in translation test servers.
  before_action :fetch_translations if APP_CONFIG.update_translations_on_every_page_load == "true"

  #this shuold be last
  before_action :push_reported_analytics_event_to_js
  before_action :push_reported_gtm_data_to_js

  helper_method :root, :logged_in?, :current_user?

  attr_reader :current_user

  def redirect_removed_locale
    if params[:locale] && Rails.application.config.REMOVED_LOCALES.include?(params[:locale])
      fallback = Rails.application.config.REMOVED_LOCALE_FALLBACKS[params[:locale]]
      redirect_to_locale(fallback, :moved_permanently)
    end
  end

  def set_locale
    user_locale = Maybe(@current_user).locale.or_else(nil)

    # We should fix this -- START
    #
    # There are a couple of controllers (amazon ses bounces, etc.) that
    # inherit application controller, even though they shouldn't. ApplicationController
    # has a lot of community specific filters and those controllers do not have community.
    # Thus, we need to add this kind of additional logic to make sure whether we have
    # community or not
    #
    m_community = Maybe(@current_community)
    community_locales = m_community.locales.or_else([])
    community_default_locale = m_community.default_locale.or_else("en")
    community_id = m_community[:id].or_else(nil)

    I18nHelper.initialize_community_backend!(community_id, community_locales) if community_id

    # We should fix this -- END

    locale = I18nHelper.select_locale(
      user_locale: user_locale,
      param_locale: params[:locale],
      community_locales: community_locales,
      community_default: community_default_locale,
      all_locales: Sharetribe::AVAILABLE_LOCALES
    )

    raise ArgumentError.new("Locale #{locale} not available. Check your community settings") unless available_locales.collect { |l| l[1] }.include?(locale)

    I18n.locale = locale
    @facebook_locale_code = I18nHelper.facebook_locale_code(Sharetribe::AVAILABLE_LOCALES, locale)

    # Store to thread the service_name used by current community, so that it can be included in all translations
    ApplicationHelper.store_community_service_name_to_thread(service_name)

    # A hack to get the path where the user is
    # redirected after the locale is changed
    new_path = request.fullpath.clone
    new_path.slice!("/#{params[:locale]}")
    new_path.slice!(0,1) if new_path =~ /^\//
    @return_to = new_path

    Maybe(@current_community).each { |community|
      @community_customization = community.community_customizations.where(locale: locale).first
    }
  end

  def set_homepage_path
    present = ->(x) { x.present? }

    @homepage_path =
      case [@current_community, @current_user, params[:locale]]
      when matches([nil, __, __])
        # FIXME We still have controllers that inherit application controller even though
        # they do not have @current_community
        #
        # Return nil, do nothing, but don't break
        nil

      when matches([present, nil, present])
        # We don't have @current_user.
        # Take the locale from URL param, and keep it in the URL if the locale
        # differs from community default
        if params[:locale] != @current_community.default_locale.to_s
          homepage_with_locale_path
        else
          homepage_without_locale_path(locale: nil)
        end

      else
        homepage_without_locale_path(locale: nil)
      end
  end


  # If URL contains locale parameter that doesn't match with the selected locale,
  # redirect to the selected locale
  def redirect_locale_param
    param_locale_not_selected = params[:locale].present? && params[:locale] != I18n.locale.to_s

    redirect_to_locale(I18n.locale, :temporary_redirect) if param_locale_not_selected
  end

  def redirect_to_locale(new_locale, status)
    if @current_community.default_locale == new_locale.to_s
      redirect_to url_for(params.to_unsafe_hash.symbolize_keys.except(:locale).merge(only_path: true)), :status => status
    else
      redirect_to url_for(params.to_unsafe_hash.symbolize_keys.merge(locale: new_locale, only_path: true)), :status => status
    end
  end

  #Creates a URL for root path (i18n breaks root_path helper)
  def root
    ActiveSupport::Deprecation.warn("Call to root is deprecated and will be removed in the future. Use search_path or landing_page_path instead.")
    "#{request.protocol}#{request.host_with_port}/#{params[:locale]}"
  end

  def fetch_logged_in_user
    if person_signed_in?
      @current_user = current_person
      setup_logger!(user_id: @current_user.id, username: @current_user.username)
    end
  end

  def initialize_feature_flags
    # Skip this if there is no current marketplace.
    # This allows to avoid skipping this filter in many places.
    return unless @current_community

    FeatureFlagHelper.init(community_id: @current_community.id,
                           user_id: @current_user&.id,
                           request: request,
                           is_admin: Maybe(@current_user).is_admin?.or_else(false),
                           is_marketplace_admin: Maybe(@current_user).is_marketplace_admin?(@current_community).or_else(false))
  end

  # Ensure that user accepts terms of community and has a valid email
  #
  # When user is created through Facebook, terms are not yet accepted
  # and email address might not be validated if addresses are limited
  # for current community. This filter ensures that user takes these
  # actions.
  def ensure_consent_given
    # Not logged in
    return unless @current_user

    # Admin can access
    return if @current_user.is_admin?

    if @current_user.community_membership.pending_consent?
      redirect_to pending_consent_path
    end
  end

  # Ensure that user belongs to community
  #
  # This check is in most cases useless: When user logs in we already
  # check that the user belongs to the community she is trying to log
  # in. However, after the user account separation migration in March
  # 2016, there was a possibility that user had an existing session
  # which pointed to a person_id that belonged to another
  # community. That's why we need to check the community membership
  # even after logging in.
  #
  # This extra check can be removed when we are sure that all the
  # sessions which potentially had a person_id pointing to another
  # community are all expired.
  def ensure_user_belongs_to_community
    return unless @current_user

    if !@current_user.has_admin_rights?(@current_community) && @current_user.accepted_community != @current_community

      logger.info(
        "Automatically logged out user that doesn't belong to community",
        :autologout,
        current_user_id: @current_user.id,
        current_community_id: @current_community.id,
        current_user_community_ids: @current_user.communities.map(&:id)
      )

      sign_out
      flash[:notice] = t("layouts.notifications.automatically_logged_out_please_sign_in")

      redirect_to search_path
    end
  end

  # A before filter for views that only users that are logged in can access
  #
  # Takes one parameter: A warning message that will be displayed in flash notification
  #
  # Sets the `return_to` variable to session, so that we can redirect user back to this
  # location after the user signed up.
  #
  # Returns true if user is logged in, false otherwise
  def ensure_logged_in(warning_message)
    if logged_in?
      true
    else
      session[:return_to] = request.fullpath
      flash[:warning] = warning_message
      redirect_to login_path

      false
    end
  end

  def logged_in?
    @current_user.present?
  end

  def current_user?(person)
    @current_user && @current_user.id.eql?(person.id)
  end

  # Saves current path so that the user can be
  # redirected back to that path when needed.
  def save_current_path
    session[:return_to_content] = request.fullpath
  end

  def save_current_host_with_port
    # store the host of the current request (as sometimes needed in views)
    @current_host_with_port = request.host_with_port
  end

  # This can be overriden by controllers, if they have
  # another strategy for resolving the community
  def resolve_community
    request.env[:current_marketplace]
  end

  # Before filter to get the current community
  def fetch_community
    @current_community = resolve_community()
    m_community = Maybe(@current_community)

    # Save current community id in request env to be used
    # by Devise and our custom community authenticatable strategy
    request.env[:community_id] = m_community.id.or_else(nil)

    setup_logger!(marketplace_id: m_community.id.or_else(nil), marketplace_ident: m_community.ident.or_else(nil))
  end

  # Performs redirect to correct URL, if needed.
  # Note: This filter is safe to run even if :fetch_community
  # filter is skipped
  def perform_redirect
    redirect_params = {
      community: @current_community,
      plan: @current_plan,
      request: request
    }

    MarketplaceRouter.perform_redirect(redirect_params) do |target|
      url = target[:url] || send(target[:route_name], protocol: target[:protocol])
      redirect_to(url, status: target[:status])
    end
  end

  def fetch_community_membership
    if @current_user
      @current_community_membership = CommunityMembership.where(person_id: @current_user.id, community_id: @current_community.id, status: "accepted").first

      if (@current_community_membership && !date_equals?(@current_community_membership.last_page_load_date, Date.today))
        Delayed::Job.enqueue(PageLoadedJob.new(@current_community_membership.id, request.host))
      end
    end
  end

  def cannot_access_if_banned
    # Not logged in
    return unless @current_user

    # Admin can access
    return if @current_user.is_admin?

    # Check if banned
    if @current_user.banned?
      flash.keep
      redirect_to access_denied_path
    end
  end

  def cannot_access_without_confirmation
    # Not logged in
    return unless @current_user

    # Admin can access
    return if @current_user.is_admin?

    if @current_user.community_membership.pending_email_confirmation?
      # Check if requirements are already filled, but the membership just hasn't been updated yet
      # (This might happen if unexpected error happens during page load and it shouldn't leave people in loop of of
      # having email confirmed but not the membership)
      #
      # TODO Remove this. Find the issue that causes this and fix it, don't fix the symptoms.
      if @current_user.has_valid_email_for_community?(@current_community)
        @current_community.approve_pending_membership(@current_user)
        redirect_to search_path and return
      end

      redirect_to confirmation_pending_path
    end
  end

  def fetch_community_admin_status
    @is_current_community_admin = (@current_user && @current_user.has_admin_rights?(@current_community))
  end

  def fetch_community_plan_expiration_status
    @current_plan = request.env[:current_plan]
  end

  # Before filter for PayPal, shows notification if user is not ready for payments
  def warn_about_missing_payment_info
    if @current_user
      missing_paypal = PaypalHelper.open_listings_with_missing_payment_info?(@current_user.id, @current_community.id)
      missing_stripe = StripeHelper.open_listings_with_missing_payment_info?(@current_user.id, @current_community.id)

      payment_settings_link = view_context.link_to(t("paypal_accounts.from_your_payment_settings_link_text"),
        person_payment_settings_path(@current_user), target: "_blank")

      if missing_paypal && missing_stripe
        flash.now[:warning] = t("stripe_accounts.missing_payment", settings_link: payment_settings_link).html_safe
      end
    end
  end

  def maintenance_warning
    now = Time.now
    @show_maintenance_warning = NextMaintenance.show_warning?(15.minutes, now)
    @minutes_to_maintenance = NextMaintenance.minutes_to(now)
  end

  # This hook will be called by Devise after successful Facebook
  # login.
  #
  # Return path where you want the user to be redirected to.
  #
  def after_sign_in_path_for(resourse)
    return_to_path = session[:return_to] || session[:return_to_content]

    if return_to_path
      flash[:notice] = flash.alert if flash.alert # Devise sets flash.alert in case already logged in
      session[:return_to] = nil
      session[:return_to_content] = nil
      return_to_path
    else
      search_path
    end
  end

  def set_display_expiration_notice
    ext_service_active = PlanService::API::Api.plans.active?
    is_expired = Maybe(@current_plan)[:expired].or_else(false)

    @display_expiration_notice = ext_service_active && is_expired
  end

  private

  # Override basic instrumentation and provide additional info for
  # lograge to consume. These are pulled and logged in environment
  # configs.
  def append_info_to_payload(payload)
    super
    payload[:community_id] = Maybe(@current_community).id.or_else("")
    payload[:current_user_id] = Maybe(@current_user).id.or_else("")

    ControllerLogging.append_request_info_to_payload!(request, payload)
  end

  def date_equals?(date, comp)
    date && date.to_date.eql?(comp)
  end

  def ensure_is_admin
    unless @is_current_community_admin
      flash[:error] = t("layouts.notifications.only_kassi_administrators_can_access_this_area")
      redirect_to search_path and return
    end
  end

  def ensure_is_superadmin
    unless Maybe(@current_user).is_admin?.or_else(false)
      flash[:error] = t("layouts.notifications.only_kassi_administrators_can_access_this_area")
      redirect_to search_path and return
    end
  end

  # Does a push to Google Analytics on next page load
  # the reason to go via session is that the actions that cause events
  # often do a redirect.
  # This is still not fool proof as multiple redirects would lose
  def report_analytics_event(category, action, opt_label)
    session[:analytics_event] = [category, action, opt_label]
  end

  # Does a push to Google Tag Manager on next page load
  # same disclaimers as before apply
  def report_to_gtm(map)
    session[:gtm_datalayer] = map
  end

  # if session has analytics event
  # report that and clean session
  def push_reported_analytics_event_to_js
    if session[:analytics_event]
      @analytics_event = session[:analytics_event]
      session.delete(:analytics_event)
    end
  end

  def push_reported_gtm_data_to_js
    if session[:gtm_datalayer]
      @gtm_datalayer = session[:gtm_datalayer]
      session.delete(:gtm_datalayer)
    end
  end

  def fetch_translations
    WebTranslateIt.fetch_translations
  end

  def check_http_auth
    return true unless APP_CONFIG.use_http_auth.to_s.downcase == 'true'
    if authenticate_with_http_basic { |u, p| u == APP_CONFIG.http_auth_username && p == APP_CONFIG.http_auth_password }
      true
    else
      request_http_basic_authentication
    end
  end

  def check_auth_token
    user_to_log_in = UserService::API::AuthTokens::use_token_for_login(params[:auth])
    person = Person.find(user_to_log_in[:id]) if user_to_log_in

    if person
      sign_in(person)
      @current_user = person

      # Clean the URL from the used token
      path_without_auth_token = URLUtils.remove_query_param(request.fullpath, "auth")
      redirect_to path_without_auth_token
    end

  end

  def logger
    if @logger.nil?
      metadata = [:marketplace_id, :marketplace_ident, :user_id, :username, :request_uuid]
      @logger = SharetribeLogger.new(:controller, metadata)
      @logger.add_metadata(request_uuid: request.uuid)
    end

    @logger
  end

  def setup_logger!(metadata)
    logger.add_metadata(metadata)
  end

  def display_branding_info?
    !params[:controller].starts_with?("admin") && !@current_plan[:features][:whitelabel]
  end
  helper_method :display_branding_info?

  def display_onboarding_topbar?
    # Don't show if user is not logged in
    return false unless @current_user

    # Show for super admins
    return true if @current_user.is_admin?

    # Show for admins if their status is accepted
    @current_user.is_marketplace_admin?(@current_community) &&
      @current_user.community_membership.accepted?
  end

  helper_method :display_onboarding_topbar?

  def onboarding_topbar_props
    community_id = @current_community.id
    onboarding_status = Admin::OnboardingWizard.new(community_id).setup_status
    {
      progress: OnboardingViewUtils.progress(onboarding_status),
      next_step: OnboardingViewUtils.next_incomplete_step(onboarding_status)
    }
  end

  helper_method :onboarding_topbar_props

  def topbar_props
    TopbarHelper.topbar_props(
      community: @current_community,
      path_after_locale_change: @return_to,
      user: @current_user,
      search_placeholder: @community_customization&.search_placeholder,
      current_path: request.fullpath,
      locale_param: params[:locale],
      host_with_port: request.host_with_port)
  end

  helper_method :topbar_props

  def notifications_to_react
    # Different way to display flash messages on React pages
    if (params[:controller] == "homepage" && params[:action] == "index" && FeatureFlagHelper.feature_enabled?(:searchpage_v1))
      notifications = [:notice, :warning, :error].each_with_object({}) do |level, acc|
        if flash[level]
          acc[level] = flash[level]
          flash.delete(level)
        end
      end.compact
    end
  end

  helper_method :notifications_to_react

  def header_props
    user = Maybe(@current_user).map { |u|
      {
        unread_count: MarketplaceService::Inbox::Query.notification_count(u.id, @current_community.id),
        avatar_url: u.image.present? ? u.image.url(:thumb) : view_context.image_path("profile_image/thumb/missing.png"),
        current_user_name: PersonViewUtils.person_display_name(u, @current_community),
        inbox_path: person_inbox_path(u),
        profile_path: person_path(u),
        manage_listings_path: person_path(u, show_closed: true),
        settings_path: person_settings_path(u),
        logout_path: logout_path
      }
    }.or_else({})

    locale_change_links = available_locales.map { |(title, locale_code)|
      {
        url: PathHelpers.change_locale_path(is_logged_in: @current_user.present?,
                                            locale: locale_code,
                                            redirect_uri: @return_to),
        title: title
      }
    }

    common = {
      logged_in: @current_user.present?,
      homepage_path: @homepage_path,
      current_locale_name: get_full_locale_name(I18n.locale),
      sign_up_path: sign_up_path,
      login_path: login_path,
      new_listing_path: new_listing_path,
      locale_change_links: locale_change_links,
      icons: pick_icons(
        APP_CONFIG.icon_pack,
        [
          "dropdown",
          "mail",
          "user",
          "list",
          "settings",
          "logout",
          "rows",
          "home",
          "new_listing",
          "information",
          "feedback",
          "invite",
          "redirect",
          "admin"
        ])
    }

    common.merge(user)
  end

  helper_method :header_props

  def get_full_locale_name(locale)
    Maybe(Sharetribe::AVAILABLE_LOCALES.find { |l| l[:ident] == locale.to_s })[:name].or_else(locale).to_s
  end

  def render_not_found!(msg = "Not found")
    raise ActionController::RoutingError.new(msg)
  end
end
