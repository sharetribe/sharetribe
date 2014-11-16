require 'will_paginate/array'

class ApplicationController < ActionController::Base
  module DefaultURLOptions
    # Adds locale to all links
    def default_url_options
      { :locale => I18n.locale }
    end
  end

  include ApplicationHelper
  include DefaultURLOptions
  protect_from_forgery
  layout 'application'

  before_filter :show_maintenance_page

  before_filter :force_ssl,
    :check_auth_token,
    :fetch_logged_in_user,
    :dashboard_only,
    :single_community_only,
    :fetch_community,
    :fetch_community_membership,
    :set_locale,
    :generate_event_id,
    :set_default_url_for_mailer
  before_filter :cannot_access_without_joining, :except => [ :confirmation_pending, :check_email_availability]
  before_filter :can_access_only_organizations_communities
  before_filter :check_email_confirmation, :except => [ :confirmation_pending, :check_email_availability_and_validity]

  # This updates translation files from WTI on every page load. Only useful in translation test servers.
  before_filter :fetch_translations if APP_CONFIG.update_translations_on_every_page_load == "true"

  #this shuold be last
  before_filter :push_reported_analytics_event_to_js

  rescue_from RestClient::Unauthorized, :with => :session_unauthorized

  helper_method :root, :logged_in?, :current_user?

  def set_locale

    locale = (logged_in? && @current_community && @current_community.locales.include?(@current_user.locale)) ? @current_user.locale : params[:locale]

    if locale.blank? && @current_community
      locale = @current_community.default_locale
    end

    if ENV['RAILS_ENV'] == 'test'
      I18n.locale = locale
    else
      I18n.locale = available_locales.collect { |l| l[1] }.include?(locale) ? locale : APP_CONFIG.default_locale
    end

    # A hack to get the path where the user is
    # redirected after the locale is changed
    new_path = request.fullpath.clone
    new_path.slice!("/#{params[:locale]}")
    new_path.slice!(0,1) if new_path =~ /^\//
    @return_to = new_path

    if @current_community
      unless @community_customization = @current_community.community_customizations.find_by_locale(I18n.locale)
        @community_customization = @current_community.community_customizations.find_by_locale(@current_community.locales.first)
      end
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

  # Before filter for actions that are only allowed on dashboard
  def dashboard_only
    return if controller_name.eql?("passwords")
    redirect_to root and return unless on_dashboard?
  end

  # Before filter for actions that are only allowed on a single community
  def single_community_only
    return if controller_name.eql?("passwords")
    redirect_to root and return if on_dashboard?
  end

  # Before filter to get the current community
  def fetch_community_by_strategy(&block)
    unless on_dashboard?
      # Otherwise pick the domain normally from the request subdomain or custom domain
      if @current_community = block.call
        # Store to thread the service_name used by current community, so that it can be included in all translations
        ApplicationHelper.store_community_service_name_to_thread(service_name)
      else
        # No community found with this domain, so redirecting to dashboard.
        redirect_to "http://www.#{APP_CONFIG.domain}"
      end
    end
  end

  # Before filter to get the current community
  def fetch_community
    # store the host of the current request (as sometimes needed in views)
    @current_host_with_port = request.host_with_port

    fetch_community_by_strategy {
      Community.find_by_domain(request.host)
    }
  end

  # Before filter to check if current user is the member of this community
  # and if so, find the membership
  def fetch_community_membership
    if @current_user
      if @current_user.communities.include?(@current_community)
        @current_community_membership = CommunityMembership.find_by_person_id_and_community_id_and_status(@current_user.id, @current_community.id, "accepted")
        unless @current_community_membership.last_page_load_date && @current_community_membership.last_page_load_date.to_date.eql?(Date.today)
          Delayed::Job.enqueue(PageLoadedJob.new(@current_community_membership.id, request.host))
        end
      end
    end
  end

  # Before filter to direct a logged-in non-member to join tribe form
  def cannot_access_without_joining
    if @current_user && ! (on_dashboard? || @current_community_membership || @current_user.is_admin?)

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
    if @current_community && @current_user && @current_user.pending_email_confirmation_to_join?(@current_community)
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

  def person_belongs_to_current_community
    @person = Person.find(params[:person_id] || params[:id])
    raise ActiveRecord::RecordNotFound.new('Not Found') unless @person.communities.include?(@current_community)
  end


  private

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
    unless @current_user && @current_community && @current_user.has_admin_rights_in?(@current_community)
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
      redirect_to("https://#{request.host_with_port}#{request.fullpath}") unless request.ssl? || ( request.headers["HTTP_VIA"] && request.headers["HTTP_VIA"].include?("sharetribe_proxy")) || request.fullpath == "/robots.txt"
    end
  end

  def show_maintenance_page
    if APP_CONFIG.show_maintenance_page
      render :file => "public/errors/maintenance.html", :layout => false and return
    end
  end

end
