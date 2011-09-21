class ApplicationController < ActionController::Base
  include UrlHelper, ApplicationHelper
  protect_from_forgery
  layout 'application'
  
  before_filter :fetch_logged_in_user, :fetch_community, :set_locale, :generate_event_id, :set_default_url_for_mailer
  before_filter :check_email_confirmation, :except => [ :confirmation_pending]
  
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
    if session[:person_id]
      @current_user = Person.find_by_id(session[:person_id])
      unless session[:cookie]
        # If there is no ASI-cookie for this session, log out completely
        clear_user_session
      end
      unless @current_user.last_page_load_date && @current_user.last_page_load_date.to_date.eql?(Date.today)
        Delayed::Job.enqueue(PageLoadedJob.new(@current_user.id, request.host))
      end
    end
  end
  
  # A before filter for views that only users that are logged in can access
  def ensure_logged_in(warning_message)
    return if logged_in?
    session[:return_to] = request.fullpath
    flash[:warning] = warning_message
    redirect_to new_session_path and return
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
    @current_user ? @current_user.id.eql?(person.id) : false
  end
  
  # Saves current path so that the user can be
  # redirected back to that path when needed.
  def save_current_path
    session[:return_to_content] = request.fullpath
  end
  
  def fetch_community
    # if in dashboard, no community to fetch, just return
    return if ["contact_requests", "dashboard", "i18n"].include?(controller_name)
        
    # if form posted to login-domain, pick community domain from origin url
    login_subdomain = APP_CONFIG.login_domain[/([^\.\/]+)\./,1] if APP_CONFIG.login_domain
    if login_subdomain && request.subdomain == login_subdomain
      fetch_community_for_login_domain
      return
    end
    
    # Redirect to root if trying to do a non-dashboard action in dashboard domain
    redirect_to root_url(:subdomain => false) and return if ["", "www"].include?(request.subdomain)
    
    # Otherwise pick the domain normally from the request subdomain
    if @current_community = Community.find_by_domain(request.subdomain)
      if @current_user && !@current_user.communities.include?(@current_community)
        # Show notification "you are not a member in this community"
      end
    else
      redirect_to root_url(:subdomain => "www")
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
    ActionMailer::Base.default_url_options = {:host => request.host_with_port}
  end
  
  def person_belongs_to_current_community
    @person = Person.find(params[:person_id] || params[:id])
    redirect_to not_member_people_path and return unless @person.communities.include?(@current_community)
  end
  
  private

  # If request comes to login domain that is common to all communities, the community cannot be fetched directly from the subdomain
  # There are also possible error cases, if wrong requests come to login domain.
  # It's meant for only POST requests to sessions or people, i.e. the requests that may contain passwords and thus better be https
  def fetch_community_for_login_domain
    
    # check if the request is allowed to login domain. Only POST to people or sessions.
    unless ["sessions", "people"].include?(controller_name) && request.method == "POST"
      
      # If referer is blank, impossible to return to right community.
      if ApplicationHelper.pick_referer_domain_part_from_request(request).blank?
        # Detect if request came to non people/session controller with longer request path than just locale
        if ! ["sessions", "people"].include?(controller_name) && request.headers["REQUEST_PATH"] && request.headers["REQUEST_PATH"].length > 4
          # This can be the case if people click links in old emails that have the login.kassi.eu/... url
          # Temporarily, to keep the old links working, we change this now to aalto.
          # In the future, this should just render an error probably.
          # Because only session related actions should be posted to login-url
          ApplicationHelper.send_error_notification("Got a wrong request (from #{ApplicationHelper.pick_referer_domain_part_from_request(request)}) to login-url, redirecting to aalto.kassi.eu#{request.headers["REQUEST_PATH"]}", "Login-domain-redirect error", params)
          redirect_to "http://aalto.kassi.eu#{request.headers["REQUEST_PATH"]}" and return
          # TODO: Change this to be an error case instead of Aalto specific redirection.
        else
          # Otherwise just display error. We do not know from which community the user came from (no HTTP_REFERER) so we show
          # an error page without links and user has to click back in the browser
          ApplicationHelper.send_error_notification("Got a wrong request (from #{ApplicationHelper.pick_referer_domain_part_from_request(request)}) to login-url. Showing error page.}", "Login-domain error", params.merge({:request_path => request.headers["REQUEST_PATH"]}))
          render "public/501.html", :layout => false and return
        end
      else # HTTP_REFERER is known: redirect back there with error message
         I18n.locale = params[:locale] if params[:locale]
        flash[:error] = ["error_with_session", t("layouts.notifications.login_again"), new_session_path]
        redirect_to "#{ApplicationHelper.pick_referer_domain_part_from_request(request)}/#{ I18n.locale}"
      end
      
    end
    
    
    
    origin_subdomain = params[:community] || ApplicationHelper.pick_referer_domain_part_from_request(request)[/\/\/([^\.]+)\./, 1]
    @current_community = Community.find_by_domain(origin_subdomain)
  end

  def session_unauthorized
    # For some reason, ASI session is no longer valid => log the user out
    clear_user_session
    flash[:error] = ["error_with_session", t("layouts.notifications.login_again"), new_session_path]
    ApplicationHelper.send_error_notification("ASI session was unauthorized. This may be normal, if session just expired, but if this occurs frequently something is wrong.", "ASI session error", params)
    redirect_to root_path and return
  end
  
  def clear_user_session
    @current_user = session[:person_id] = session[:cookie] = nil
  end
  
  # this generates the event_id that will be used in 
  # requests to cos during this kassi-page view only
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
      begin
        if (params["file"] || (params["listing"] && params["listing"]["listing_images_attributes"]))
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
    unless @current_user && @current_user.is_admin?
      flash[:error] = "only_kassi_administrators_can_access_this_area"
      redirect_to root and return
    end
  end
  
  def fetch_translations
    WebTranslateIt.fetch_translations
  end
  
end
