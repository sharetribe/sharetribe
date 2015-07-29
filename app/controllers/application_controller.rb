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
  include FeatureFlagHelper
  include DefaultURLOptions
  protect_from_forgery
  layout 'application'

  before_filter :redirect_to_marketplace_ident,
    :force_ssl,
    :check_auth_token,
    :fetch_logged_in_user,
    :fetch_community,
    :redirect_deleted_marketplace,
    :redirect_to_marketplace_domain,
    :fetch_community_membership,
    :redirect_removed_locale,
    :set_locale,
    :redirect_locale_param,
    :generate_event_id,
    :set_default_url_for_mailer,
    :fetch_chargebee_plan_data,
    :fetch_community_admin_status,
    :fetch_community_plan_expiration_status,
    :warn_about_missing_payment_info,
    :set_homepage_path
  before_filter :cannot_access_without_joining, :except => [ :confirmation_pending, :check_email_availability]
  before_filter :can_access_only_organizations_communities
  before_filter :check_email_confirmation, :except => [ :confirmation_pending, :check_email_availability_and_validity]

  # This updates translation files from WTI on every page load. Only useful in translation test servers.
  before_filter :fetch_translations if APP_CONFIG.update_translations_on_every_page_load == "true"

  #this shuold be last
  before_filter :push_reported_analytics_event_to_js

  rescue_from RestClient::Unauthorized, :with => :session_unauthorized

  helper_method :root, :logged_in?, :current_user?

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
    end
  end

  # A before filter for views that only users that are logged in can access
  def ensure_logged_in(warning_message)
    return if logged_in?
    session[:return_to] = request.fullpath
    flash[:warning] = warning_message
    redirect_to login_path and return
  end

  # A before filter for views that only authorized users can access
  def ensure_authorized(error_message)
    if logged_in?
      @person = Person.find(params[:person_id] || params[:id])
      return if current_user?(@person)
    end

    # This is reached only if not authorized
    flash[:error] = error_message
    redirect_to root and return
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

  # Before filter to get the current community
  def fetch_community_by_strategy(&block)
    # Pick the community according to the given strategy
    @current_community = block.call

    unless @current_community
      # No community found with the strategy, so redirecting to redirect url, or error page.
      redirect_to Maybe(APP_CONFIG).community_not_found_redirect.or_else {
        no_communities = Community.count == 0

        if no_communities
          new_community_path
        else
          :community_not_found
        end
      }
    end
  end

  # Before filter to get the current community
  def fetch_community
    # store the host of the current request (as sometimes needed in views)
    @current_host_with_port = request.host_with_port

    fetch_community_by_strategy {
      ApplicationController.default_community_fetch_strategy(request.host)
    }
  end

  def redirect_deleted_marketplace
    if Maybe(@current_community).deleted?.or_else(false)
      redirect_to Maybe(APP_CONFIG).community_not_found_redirect.or_else(:community_not_found)
    end
  end

  def redirect_to_marketplace_domain
    return unless @current_community

    host = request.host
    domain = @current_community.domain

    redirect_opts = request_hash.slice(:host, :protocol, :fullpath).merge(community_domain: domain, domain_ready: domain.present?)

    MarketplaceRedirectUtils.needs_redirect(redirect_opts) { |redirect_url, redirect_status|
      redirect_to(redirect_url, status: redirect_status)
    }
  end

  def request_hash
    @request_hash ||= {
      host: request.host,
      protocol: request.protocol,
      fullpath: request.fullpath
    }
  end

  def redirect_to_marketplace_ident
    host = request.host
    app_domain = URLUtils.strip_port_from_host(APP_CONFIG.domain)
    if host.end_with?(app_domain) && host.start_with?("www.")
      ident_without_www = host.sub(/www\./, '').chomp(".#{app_domain}")
      return redirect_to "#{request.protocol}#{ident_without_www}.#{APP_CONFIG.domain}", status: 301
    end
  end

  # Fetch community
  #
  # 1. Try to find by domain
  # 2. If there is only one community, use it
  # 3. Otherwise nil
  #
  def self.default_community_fetch_strategy(domain)
    raise ArgumentError("Domain cannot be nil.") if domain.nil?

    community = Community.where(domain: domain).first
    return community if community.present?

    app_domain = URLUtils.strip_port_from_host(APP_CONFIG.domain)
    ident = domain.chomp(".#{app_domain}")
    community = Community.where(ident: ident).first
    return community if community.present?

    # If only one, use it
    return Community.first if Community.count == 1

    # Not found, return nil
    nil
  end

  def fetch_community_membership
    if @current_user
      @current_community_membership = CommunityMembership.where(person_id: @current_user.id, community_id: @current_community.id, status: "accepted").first

      if (@current_community_membership && !date_equals?(@current_community_membership.last_page_load_date, Date.today))
        Delayed::Job.enqueue(PageLoadedJob.new(@current_community_membership.id, request.host))
      end
    end
  end

  # Before filter to direct a logged-in non-member to join tribe form
  def cannot_access_without_joining
    if @current_user && ! (@current_community_membership || @current_user.is_admin?)

      # Check if banned
      if @current_community && @current_user && @current_user.banned_at?(@current_community)
        flash.keep
        redirect_to access_denied_tribe_memberships_path and return
      end

      session[:invitation_code] = params[:code] if params[:code]
      flash.keep
      redirect_to new_tribe_membership_path
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

  def check_email_confirmation
    # If confirmation is required, but not done, redirect to confirmation pending announcement page
    # (but allow confirmation to come through)
    if @current_community && @current_user && @current_user.pending_email_confirmation_to_join?(@current_community_membership)
      flash[:warning] = t("layouts.notifications.you_need_to_confirm_your_account_first")
      redirect_to :controller => "sessions", :action => "confirmation_pending" unless params[:controller] == 'devise/confirmations'
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
    @is_current_community_admin = @current_user && @current_user.has_admin_rights_in?(@current_community)
  end

  def fetch_community_plan_expiration_status
    @is_community_plan_expired = MarketplaceService::Community::Query.is_plan_expired(@current_community)
  end

  def fetch_chargebee_plan_data
    @pro_biannual_link = APP_CONFIG.chargebee_pro_biannual_link
    @pro_biannual_price = APP_CONFIG.chargebee_pro_biannual_price
    @pro_monthly_link = APP_CONFIG.chargebee_pro_monthly_link
    @pro_monthly_price = APP_CONFIG.chargebee_pro_monthly_price
  end

  # Before filter for PayPal, shows notification if user is not ready for payments
  def warn_about_missing_payment_info
    if @current_user && PaypalHelper.open_listings_with_missing_payment_info?(@current_user.id, @current_community.id)
      settings_link = view_context.link_to(t("paypal_accounts.from_your_payment_settings_link_text"), payment_settings_path(:paypal, @current_user))
      warning = t("paypal_accounts.missing", settings_link: settings_link)
      flash.now[:warning] = warning.html_safe
    end
  end

  private

  # Override basic instrumentation and provide additional info for lograge to consume
  # These are further configured in environment configs
  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:community_id] = Maybe(@current_community).id.or_else("")
    payload[:current_user_id] = Maybe(@current_user).id.or_else("")
    payload[:request_uuid] = request.env["HTTP_X_REQUEST_ID"]
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
  def report_analytics_event(params_array)
    session[:analytics_event] = params_array
  end

  # if session has analytics event
  # report that and clean session
  def push_reported_analytics_event_to_js
    if session[:analytics_event]
      @analytics_event = session[:analytics_event]
      session.delete(:analytics_event)
    end
  end

  def fetch_translations
    WebTranslateIt.fetch_translations
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

  def force_ssl
    # If defined in the config, always redirect to https (unless already using https or coming through Sharetribe proxy)
    if APP_CONFIG.always_use_ssl
      redirect_to("https://#{request.host_with_port}#{request.fullpath}", status: 301) unless request.ssl? || ( request.headers["HTTP_VIA"] && request.headers["HTTP_VIA"].include?("sharetribe_proxy")) || ApplicationController.should_not_redirect_path_to_https(request.fullpath)
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
  #   ensure_feature_enabled, :shipping, only: [:new_shipping, edit_shipping]
  #   ...
  #  end
  #
  def self.ensure_feature_enabled(feature_name, options = {})
    before_filter(options) { ensure_feature_enabled(feature_name) }
  end

  # Returns `true` if the path is such that the app should NOT
  # redirect to HTTPS.
  #
  # Paths that should not be redirected are for example robots.txt and
  # domain validation files.
  #
  def self.should_not_redirect_path_to_https(fullpath)
    dv_regexp = /^\/[a-zA-Z0-9]+\.txt$/

    (
      # robots.txt should not be redirected
      fullpath == "/robots.txt" ||

      # matches to Domain Validation file regex, should not redirect
      dv_regexp.match(fullpath).nil? == false
    )
  end
end
