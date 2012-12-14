require 'will_paginate/array'

class ApplicationController < ActionController::Base
  include UrlHelper, ApplicationHelper
  protect_from_forgery
  layout 'application'

  before_filter :show_maintenance_page

  before_filter :domain_redirect, :force_ssl, :fetch_logged_in_user, :dashboard_only, :single_community_only, :fetch_community, :not_public_in_private_community, :fetch_community_membership,  :cannot_access_without_joining, :set_locale, :generate_event_id, :set_default_url_for_mailer
  before_filter :check_email_confirmation, :except => [ :confirmation_pending, :check_email_availability_and_validity]


  # after filter would be more logical, but then log would be skipped when action cache is hit.
  before_filter :log_to_ressi if APP_CONFIG.log_to_ressi

  # This updates translation files from WTI on every page load. Only useful in translation test servers.
  before_filter :fetch_translations if APP_CONFIG.update_translations_on_every_page_load

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
  end

  # Adds locale to all links
  def default_url_options(options={})
    { :locale => I18n.locale }
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
      flash[:error] = error_message
      redirect_to root and return
    end
  end

  def logged_in?
    ! @current_user.nil?
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
  def fetch_community
    unless on_dashboard?
      # Otherwise pick the domain normally from the request subdomain
      if @current_community = Community.find_by_domain(request.subdomain)
        # Store to thread the service_name used by current community, so that it can be included in all translations
        ApplicationHelper.store_community_service_name_to_thread(service_name)
      else
        # No community found with this domain, so redirecting to dashboard.
        redirect_to root_url(:subdomain => "www")
      end
    end
  end
  
  # Before filter to make sure non logged in users cannot access private communities
  def not_public_in_private_community
    return if controller_name.eql?("passwords")
    if @current_community && @current_community.private? && !@current_user
      @container_class = "container_12"
      @private_layout = true
      set_locale 
      redirect_to :controller => :homepage, :action => :sign_in
    end
  end
  
  # Before filter to check if current user is the member of this community
  # and if so, find the membership
  def fetch_community_membership
    if @current_user
      if @current_user.communities.include?(@current_community)
        @current_community_membership = CommunityMembership.find_by_person_id_and_community_id(@current_user.id, @current_community.id)
        unless @current_community_membership.last_page_load_date && @current_community_membership.last_page_load_date.to_date.eql?(Date.today)
          Delayed::Job.enqueue(PageLoadedJob.new(@current_community_membership.id, request.host))
        end
      end
    end
  end
  
  # Before filter to direct a logged-in non-member to join tribe form
  def cannot_access_without_joining
    if @current_user
      redirect_to new_tribe_membership_path unless on_dashboard? || @current_community_membership || @current_user.is_admin?
    end
  end

  def check_email_confirmation
    # If confirmation is required, but not done, redirect to confirmation pending announcement page
    # (but allow confirmation to come through)
    if @current_community && @current_community.email_confirmation && @current_user && @current_user.confirmed_at.blank?
      flash[:warning] = "you_need_to_confirm_your_account_first"
      redirect_to :controller => "sessions", :action => "confirmation_pending" unless params[:controller] == 'devise/confirmations'
    end
  end

  def set_default_url_for_mailer
    url = community_url(request.host_with_port, @current_community)
    ActionMailer::Base.default_url_options = {:host => url}
  end

  def person_belongs_to_current_community
    @person = Person.find(params[:person_id] || params[:id])
    redirect_to not_member_people_path and return unless @person.communities.include?(@current_community)
  end

  private

  def session_unauthorized
    # For some reason, ASI session is no longer valid => log the user out
    clear_user_session
    flash[:error] = ["error_with_session", t("layouts.notifications.login_again"), login_path]
    ApplicationHelper.send_error_notification("ASI session was unauthorized. This may be normal, if session just expired, but if this occurs frequently something is wrong.", "ASI session error", params)
    redirect_to root_path and return
  end

  def clear_user_session
    @current_user = session[:person_id] = session[:cookie] = nil
  end

  # this generates the event_id that will be used in
  # requests to cos during this Sharetribe-page view only
  def generate_event_id
    RestHelper.event_id = "#{EventIdHelper.generate_event_id(params)}_#{Time.now.to_f}"
    # The event id is generated here and stored for the duration of this request.
    # The option above stores it to thread which should work fine on mongrel
  end

  def log_to_ressi

    # These are the fields that are currently stored in Ressi, so no need to store others
    relevant_header_fields = ["HTTP_USER_AGENT","REQUEST_URI", "HTTP_REFERER"]

    CachedRessiEvent.create do |e|
      e.user_id           = @current_user ? @current_user.id : nil
      e.application_id    = "acm-TkziGr3z9Tab_ZvnhG"
      e.session_id        = request.session_options ? request.session_options[:id] : nil
      e.ip_address        = request.remote_ip
      e.action            = "#{self.class}\##{action_name}"
      e.test_group_number = @current_user ? @current_user.test_group_number : nil
      e.community_id      = @current_community ? @current_community.id : nil
      begin
        if (params["file"] || params["image"] || (params["listing"] && params["listing"]["listing_images_attributes"] ||
            params["person"] && params["person"]["image"]))
          # This case breaks iomage upload (reason unknown) if we use to_json, so we'll have to skip it 
          e.parameters    = params.inspect.gsub('=>', ':')
        else  #normal case
          e.parameters    = request.filtered_parameters.to_json
        end
      rescue JSON::GeneratorError => error
        e.parameters      = ["There was error in genarating the JSON from the parameters."].to_json
      end
      e.return_value      = @_response.status
      e.semantic_event_id = RestHelper.event_id
      e.headers           = request.headers.reject do |key, value|
        !relevant_header_fields.include?(key)
      end.to_json
    end
  end

  def ensure_is_admin
    unless @current_user && @current_community && @current_user.has_admin_rights_in?(@current_community)
      flash[:error] = "only_kassi_administrators_can_access_this_area"
      redirect_to root and return
    end
  end

  def fetch_translations
    WebTranslateIt.fetch_translations
  end

  # returns the request_url_with_port in a way that the community subdomain is switched to be the
  # first part of the request
  # This method is used to ensure that using the community subdomain and not the login subdomain
  def  community_url(request_url_with_port, community)
    unless community.blank?
      return request_url_with_port.sub(/[^\/\.]+\./, "#{community.domain}.")
    else
      return request_url_with_port
    end
  end
  
   # # These rules are specific to the Sharetribe.com server, but shouldn't cause trouble for open source installations.
    # # And you if you need your own rules for redirection or rewrite, add here.
  def domain_redirect
    # to speed up the check on every page load, only check first 
    # if different domain than specified in config
    if request.domain != APP_CONFIG.domain && APP_CONFIG.domain == 'sharetribe.com'
      
      # Redirect contry domain dashboards to .com with correct language
      redirect_to "#{request.protocol}www.sharetribe.com/es" and return if request.host =~ /^(www\.)?sharetribe\.cl/
      redirect_to "#{request.protocol}www.sharetribe.com/en" and return if request.host =~ /^(www\.)?sharetribe\.us/ || request.host =~ /^(www\.)?sharetri\.be/
      redirect_to "#{request.protocol}www.sharetribe.com/el" and return if request.host =~ /^(www\.)?sharetribe\.gr/
      redirect_to "#{request.protocol}www.sharetribe.com/fr" and return if request.host =~ /^(www\.)?sharetribe\.fr/
      redirect_to "#{request.protocol}www.sharetribe.com/fi" and return if request.host =~ /^(www\.)?sharetribe\.fi/
      
      # Redirect to right commnunity (changing to .com)
      redirect_to "#{request.protocol}#{request.subdomain}.sharetribe.com#{request.fullpath}" and return if request.host =~ /^.+\.?sharetribe\.(cl|gr|fr|fi|us|de)/ || request.host =~ /^.+\.?sharetri\.be/  || request.host =~ /^.+\.?kassi\.eu/
      
      redirect_to "#{request.protocol}samraksh.sharetribe.com#{request.fullpath}" and return if request.host =~ /^(www\.)?samraksh\.org/
      
      
      
    end 
  end
  
  def force_ssl
    if APP_CONFIG.always_use_ssl
      redirect_to({:protocol => 'https'}.merge(params), :flash => flash) unless request.ssl?
    end
  end
  
  def show_maintenance_page
    if APP_CONFIG.show_maintenance_page
      render :file => "public/errors/maintenance.html", :layout => false and return
    end
  end
end
