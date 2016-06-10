require 'will_paginate/array'

class ApplicationController < ActionController::Base
  class FeatureFlagNotEnabledError < StandardError; end

  module DefaultURLOptions
    # Adds locale to all links
    def default_url_options
      { :locale => I18n.locale }
    end
  end

  include ApplicationHelper
  include IconHelper
  include FeatureFlagHelper
  include DefaultURLOptions
  protect_from_forgery
  layout 'application'

  before_filter :check_http_auth,
    :check_auth_token,
    :fetch_community,
    :fetch_community_plan_expiration_status,
    :perform_redirect,
    :fetch_logged_in_user,
    :save_current_host_with_port,
    :fetch_community_membership,
    :redirect_removed_locale,
    :set_locale,
    :redirect_locale_param,
    :generate_event_id,
    :set_default_url_for_mailer,
    :fetch_community_admin_status,
    :warn_about_missing_payment_info,
    :set_homepage_path,
    :report_queue_size,
    :maintenance_warning,
    :cannot_access_if_banned,
    :cannot_access_without_confirmation,
    :ensure_consent_given,
    :ensure_user_belongs_to_community,
    :can_access_only_organizations_communities

  # This updates translation files from WTI on every page load. Only useful in translation test servers.
  before_filter :fetch_translations if APP_CONFIG.update_translations_on_every_page_load == "true"

  #this shuold be last
  before_filter :push_reported_analytics_event_to_js
  before_filter :push_reported_gtm_data_to_js

  rescue_from RestClient::Unauthorized, :with => :session_unauthorized

  helper_method :root, :logged_in?, :current_user?

  attr_reader :current_user

  def redirect_removed_locale
    if params[:locale] && Kassi::Application.config.REMOVED_LOCALES.include?(params[:locale])
      fallback = Kassi::Application.config.REMOVED_LOCALE_FALLBACKS[params[:locale]]
      redirect_to_locale(fallback, :moved_permanently)
    end
  end

  def set_locale
    user_locale = Maybe(@current_user).locale.or_else(nil)

    # We should fix this -- START
    #
    # There are a couple of controllers (amazon ses bounces, braintree webhooks) that
    # inherit application controller, even though they shouldn't. ApplicationController
    # has a lot of community specific filters and those controllers do not have community.
    # Thus, we need to add this kind of additional logic to make sure whether we have
    # community or not
    #
    m_community = Maybe(@current_community)
    community_locales = m_community.locales.or_else([])
    community_default_locale = m_community.default_locale.or_else("en")
    community_id = m_community[:id].or_else(nil)
    community_backend = I18n::Backend::CommunityBackend.instance

    # Load translations from TranslationService
    if community_id
      community_backend.set_community!(community_id, community_locales.map(&:to_sym))
      community_translations = TranslationService::API::Api.translations.get(community_id)[:data]
      TranslationServiceHelper.community_translations_for_i18n_backend(community_translations).each { |locale, data|
        # Store community translations to I18n backend.
        #
        # Since the data in data hash is already flatten, we don't want to
        # escape the separators (. dots) in the key
        community_backend.store_translations(locale, data, escape: false)
      }
    end

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
      redirect_to url_for(params.except(:locale).merge(only_path: true)), :status => status
    else
      redirect_to url_for(params.merge(locale: new_locale, only_path: true)), :status => status
    end
  end

  #Creates a URL for root path (i18n breaks root_path helper)
  def root
    "#{request.protocol}#{request.host_with_port}/#{params[:locale]}"
  end

  def fetch_logged_in_user
    if person_signed_in?
      @current_user = current_person
      setup_logger!(user_id: @current_user.id, username: @current_user.username)
    end
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

    if !@current_user.is_admin? && @current_user.accepted_community != @current_community

      logger.info(
        "Automatically logged out user that doesn't belong to community",
        :autologout,
        current_user_id: @current_user.id,
        current_community_id: @current_community.id,
        current_user_community_ids: @current_user.communities.map(&:id)
      )

      sign_out
      session[:person_id] = nil
      flash[:notice] = t("layouts.notifications.automatically_logged_out_please_sign_in")

      redirect_to root
    end
  end

  # A before filter for views that only users that are logged in can access
  def ensure_logged_in(warning_message)
    return if logged_in?
    session[:return_to] = request.fullpath
    flash[:warning] = warning_message
    redirect_to login_path and return
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
    app_domain = URLUtils.strip_port_from_host(APP_CONFIG.domain)
    CurrentMarketplaceResolver.resolve_from_host(request.host, app_domain)
  end

  # Before filter to get the current community
  def fetch_community
    @current_community = resolve_community()
    m_community = Maybe(@current_community)

    # Save current community id in request env to be used
    # by Devise and our custom community authenticatable strategy
    request.env[:community_id] = m_community.id.or_else(nil)

    setup_logger!(marketplace_id: m_community.id.or_else(nil), marketplace_ident: m_community.ident.or_else(nil))

    # Save :found or :not_found to community status
    # This is needed because we need to distinguish to cases
    # where community is nil
    #
    # 1. Community is nil because it was not found
    # 2. Community is nil beucase fetch_community filter was skipped
    @community_search_status = @current_community ? :found : :not_found
  end

  def community_search_status
    @community_search_status || :skipped
  end

  # Performs redirect to correct URL, if needed.
  # Note: This filter is safe to run even if :fetch_community
  # filter is skipped
  def perform_redirect
    community = Maybe(@current_community).map { |c|
      {
        ident: c.ident,
        domain: c.domain,
        deleted: c.deleted?,
        use_domain: c.use_domain?,
        domain_verification_file: c.dv_test_file_name,
        closed: Maybe(@current_plan)[:closed].or_else(false)
      }
    }.or_else(nil)

    paths = {
      community_not_found: Maybe(APP_CONFIG).community_not_found_redirect.map { |url| {url: url} }.or_else({route_name: :community_not_found_path}),
      new_community: {route_name: :new_community_path}
    }

    configs = {
      always_use_ssl: Maybe(APP_CONFIG).always_use_ssl.map { |v| v == true || v.to_s.downcase == "true" }.or_else(false), # value can be string if it comes from ENV
      app_domain: URLUtils.strip_port_from_host(APP_CONFIG.domain),
    }

    other = {
      no_communities: Community.count == 0,
      community_search_status: community_search_status,
    }

    MarketplaceRouter.needs_redirect(
      request: request_hash,
      community: community,
      paths: paths,
      configs: configs,
      other: other) { |redirect_dest|
      url = redirect_dest[:url] || send(redirect_dest[:route_name], protocol: redirect_dest[:protocol])

      redirect_to(url, status: redirect_dest[:status])
    }
  end

  def request_hash
    @request_hash ||= {
      host: request.host,
      protocol: request.protocol,
      fullpath: request.fullpath,
      port_string: request.port_string,
      headers: request.headers
    }
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
        redirect_to root and return
      end

      redirect_to confirmation_pending_path
    end
  end

  def can_access_only_organizations_communities
    if (@current_community && @current_community.only_organizations) &&
      (@current_user && !@current_user.is_organization)

      sign_out @current_user
      flash[:warning] = t("layouts.notifications.can_not_login_with_private_user")
      redirect_to login_path
    end
  end

  def set_default_url_for_mailer
    url = @current_community ? "#{@current_community.full_domain}" : "www.#{APP_CONFIG.domain}"
    ActionMailer::Base.default_url_options = {:host => url}
    if APP_CONFIG.always_use_ssl
      ActionMailer::Base.default_url_options[:protocol] = "https"
    end
  end

  def fetch_community_admin_status
    @is_current_community_admin = @current_user && @current_user.has_admin_rights?
  end

  def fetch_community_plan_expiration_status
    Maybe(@current_community).id.each { |community_id|
      @current_plan = PlanService::API::Api.plans.get_current(community_id: community_id).data
    }
  end

  # Before filter for PayPal, shows notification if user is not ready for payments
  def warn_about_missing_payment_info
    if @current_user && PaypalHelper.open_listings_with_missing_payment_info?(@current_user.id, @current_community.id)
      settings_link = view_context.link_to(t("paypal_accounts.from_your_payment_settings_link_text"),
        payment_settings_path(:paypal, @current_user), target: "_blank")
      warning = t("paypal_accounts.missing", settings_link: settings_link)
      flash.now[:warning] = warning.html_safe
    end
  end

  def report_queue_size
    MonitoringService::Monitoring.report_queue_size
  end

  def maintenance_warning
    now = Time.now
    @show_maintenance_warning = NextMaintenance.show_warning?(15.minutes, now)
    @minutes_to_maintenance = NextMaintenance.minutes_to(now)
  end

  def current_community_id
    Maybe(@current_community).id.or_else(nil)
  end

  def current_community_custom_colors
    Maybe(@current_community)
      .map { |c|
        {
          marketplace_color1: c.custom_color1 || '#a64c5d',
          marketplace_color2: c.custom_color2 || '#00a26c'
        }
      }
      .or_else({})
  end

  private

  # Override basic instrumentation and provide additional info for lograge to consume
  # These are further configured in environment configs
  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:community_id] = Maybe(@current_community).id.or_else("")
    payload[:current_user_id] = Maybe(@current_user).id.or_else("")
    payload[:request_uuid] = request.uuid
  end

  def date_equals?(date, comp)
    date && date.to_date.eql?(comp)
  end

  def session_unauthorized
    # For some reason, ASI session is no longer valid => log the user out
    clear_user_session
    flash[:error] = t("layouts.notifications.error_with_session")
    ApplicationHelper.send_error_notification("ASI session was unauthorized. This may be normal, if session just expired, but if this occurs frequently something is wrong.", "ASI session error", params)
    redirect_to root_path and return
  end

  def clear_user_session
    @current_user = session[:person_id] = nil
  end

  # this generates the event_id that will be used in
  # requests to cos during this Sharetribe-page view only
  def generate_event_id
    RestHelper.event_id = "#{EventIdHelper.generate_event_id(params)}_#{Time.now.to_f}"
    # The event id is generated here and stored for the duration of this request.
    # The option above stores it to thread which should work fine on mongrel
  end

  def ensure_is_admin
    unless @is_current_community_admin
      flash[:error] = t("layouts.notifications.only_kassi_administrators_can_access_this_area")
      redirect_to root and return
    end
  end

  def ensure_is_superadmin
    unless Maybe(@current_user).is_admin?.or_else(false)
      flash[:error] = t("layouts.notifications.only_kassi_administrators_can_access_this_area")
      redirect_to root and return
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

  def redirect_https?
    always_use_ssl = APP_CONFIG.always_use_ssl.to_s.downcase == "true"
    !request.ssl? && always_use_ssl
  end

  def redirect_https!
    redirect_to protocol: "https://", status: :moved_permanently
  end

  def check_http_auth
    return true unless APP_CONFIG.use_http_auth.to_s.downcase == 'true'
    if authenticate_with_http_basic { |u, p| u == APP_CONFIG.http_auth_username && p == APP_CONFIG.http_auth_password }
      true
    elsif redirect_https?
      redirect_https!
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

  def feature_flags
    @feature_flags ||= fetch_feature_flags
  end

  def fetch_feature_flags
    flags_from_service = FeatureFlagService::API::Api.features.get(community_id: @current_community.id).maybe[:features].or_else(Set.new)

    is_admin = Maybe(@current_user).is_admin?.or_else(false)
    temp_flags = ApplicationController.fetch_temp_flags(is_admin, params, session)

    session[:feature_flags] = temp_flags

    flags_from_service.union(temp_flags)
  end

  helper_method :fetch_feature_flags # Make this method available for FeatureFlagHelper

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
    @current_user.is_marketplace_admin? &&
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

  def header_props
    user = Maybe(@current_user).map { |u|
      {
        unread_count: MarketplaceService::Inbox::Query.notification_count(u.id, @current_community.id),
        avatar_url: u.image.present? ? u.image.url(:thumb) : view_context.image_path("profile_image/thumb/missing.png"),
        current_user_name: u.name(@current_community),
        inbox_path: person_inbox_path(u),
        profile_path: person_path(u),
        manage_listings_path: person_path(u, show_closed: true),
        settings_path: person_settings_path(u),
        logout_path: logout_path
      }
    }.or_else({})

    common = {
      logged_in: @current_user.present?,
      homepage_path: @homepage_path,
      return_after_locale_change: @return_to,
      current_locale_name: get_full_locale_name(I18n.locale),
      sign_up_path: sign_up_path,
      login_path: login_path,
      new_listing_path: new_listing_path,
      available_locales: available_locales,
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


  # Fetch temporary flags from params and session
  def self.fetch_temp_flags(is_admin, params, session)
    return Set.new unless is_admin

    from_session = Maybe(session)[:feature_flags].or_else(Set.new)
    from_params = Maybe(params)[:enable_feature].map { |feature| [feature.to_sym] }.to_set.or_else(Set.new)

    from_session.union(from_params)
  end

  def ensure_feature_enabled(feature_name)
    raise FeatureFlagNotEnabledError unless feature_flags.include?(feature_name)
  end

  # Handy before_filter shorthand.
  #
  # Usage:
  #
  # class YourController < ApplicationController
  #   ensure_feature_enabled :shipping, only: [:new_shipping, :edit_shipping]
  #   ...
  #  end
  #
  def self.ensure_feature_enabled(feature_name, options = {})
    before_filter(options) { ensure_feature_enabled(feature_name) }
  end

  def render_not_found!(msg = "Not found")
    raise ActionController::RoutingError.new(msg)
  end
end
