class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  before_filter :fetch_logged_in_user
  before_filter :set_locale
  
  rescue_from RestClient::Unauthorized, :with => :session_unauthorized
  
  helper_method :root, :logged_in?, :current_user?
  
  def set_locale
    locale = logged_in? ? @current_user.locale : params[:locale]
      
    if ENV['RAILS_ENV'] == 'test'
      I18n.locale = locale
    else  
      I18n.locale = ["fi", "en"].include?(locale) ? locale : "fi"
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
      
      # Here used to be a check for session validity that was done on every page load
      # Now it is removed. So there is no certainty that the session is valid.
      
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
  
end
