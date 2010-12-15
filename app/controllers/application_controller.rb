class ApplicationController < ActionController::Base
  include UrlHelper
  protect_from_forgery
  layout 'application'
  
  before_filter :fetch_logged_in_user, :set_locale, :generate_event_id, :fetch_community
  
  # after filter would be more logical, but then log would be skipped when action cache is hit.
  before_filter :log_to_ressi if APP_CONFIG.log_to_ressi
  
  rescue_from RestClient::Unauthorized, :with => :session_unauthorized
  
  helper_method :root, :logged_in?, :current_user?
  
  def set_locale
    locale = logged_in? ? @current_user.locale : params[:locale]
      
    if ENV['RAILS_ENV'] == 'test'
      I18n.locale = locale
    else  
      I18n.locale = ["fi", "en"].include?(locale) ? locale : APP_CONFIG.default_locale
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
    return if ["contact_requests", "dashboard"].include?(controller_name)
    redirect_to root_url(:subdomain => false) and return if ["", "www"].include?(request.subdomain)
    if @community = Community.find_by_domain(request.subdomain)
      if @current_user && !@current_user.communities.include?(@community)
        # Show notification "you are not a member in this community"
      end
    else
      redirect_to root_url(:subdomain => "www")
    end
  end
  
  private

  def session_unauthorized
    # For some reason, ASI session is no longer valid => log the user out
    clear_user_session
    flash[:error] = ["error_with_session", t("layouts.notifications.login_again"), new_session_path]
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
    unless @current_user.is_admin?
      flash[:error] = "only_kassi_administrators_can_access_this_area"
      redirect_to root and return
    end
  end
  
end
