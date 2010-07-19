class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  before_filter :set_locale
  before_filter :fetch_logged_in_user
  
  helper_method :root, :logged_in?
  
  def set_locale
    I18n.locale = params[:locale]
    
    # A hack to get the path where the user is 
    # redirected after the locale is changed
    new_path = request.fullpath
    new_path.slice!("/#{params[:locale]}")
    new_path.slice!(0,1) if new_path =~ /^\//
    @return_to = new_path
  end
  
  # Adds locale to all links
  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
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
        @current_user = session[:person_id] = session[:cookie] = nil
      end
      
      # Here used to be a check for session validity that was done on every page load
      # Now it is removed. So there is no certainty that the session is valid.
      
    end
  end
  
  def logged_in?
    ! @current_user.nil?
  end
  
end
