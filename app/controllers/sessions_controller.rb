require 'rest_client'

class SessionsController < ApplicationController
  include UrlHelper
  
  skip_filter :check_email_confirmation
  
  def create
    # if the request came from different domain, redirects back there.
    # e.g. if using login-subdoain for logging in with https    
    if params["community"].blank?
      ApplicationHelper.send_error_notification("Got login request, but origin community is blank! Can't redirect back.", "Errors that should never happen")
    end
    current_community = Community.find_by_domain(params[:community])
    domain = "http://#{with_subdomain(current_community.domain)}"
        
    session[:form_username] = params[:username]
    begin
      @session = Session.create({ :username => params[:username], 
                                  :password => params[:password] })
    rescue RestClient::Unauthorized => e
      flash[:error] = :login_failed
      redirect_to domain + login_path and return
    end

    session[:form_username] = nil
    
    if @session.person_id  # if not app-only-session and person found in cos
      @current_user = Person.find_by_id(@session.person_id)
      # TODO: Should check here if the user is a member of current community
      
      unless @current_user && current_community.consent.eql?(@current_user.consent(current_community))
        # The user has succesfully logged in, but is not found in Kassi DB
        # Existing Sizzle user's first login in Kassi
        session[:temp_cookie] = @session.cookie
        session[:temp_person_id] = @session.person_id
        session[:temp_community_id] = current_community.id
        session[:consent_changed] = true if @current_user
        redirect_to domain + terms_path and return
      end
    end
    
    session[:cookie] = @session.cookie
    session[:person_id] = @session.person_id
      
    flash[:notice] = [:login_successful, (@current_user.given_name_or_username + "!").to_s, person_path(@current_user)]
    @current_user.update_attribute(:active, true) unless @current_user.active?
    if session[:return_to]
      redirect_to domain + session[:return_to]
      session[:return_to] = nil
    else
      redirect_to domain + root_path
    end
  end
  
  def destroy
    Session.destroy(session[:cookie]) if session[:cookie]
    session[:cookie] = nil
    session[:person_id] = nil
    flash[:notice] = :logout_successful
    redirect_to root
  end
  
  def index
    # this is not in use in Kassi, but bots seem to try the url so implementing this to avoid errors
   render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
  end
  
  def request_new_password
    begin
      RestHelper.make_request(:post, "#{APP_CONFIG.asi_url}/people/recover_password", {:email => params[:email]} ,{:cookies => Session.kassi_cookie})
      # RestClient.post("#{APP_CONFIG.asi_url}/people/recover_password", {:email => params[:email]} ,{:cookies => Session.kassi_cookie})
      flash[:notice] = :password_recovery_sent
    rescue RestClient::ResourceNotFound => e 
      flash[:error] = :email_not_found
    end
    redirect_to new_session_path
  end
  
  # This is used if user has not confirmed her email address
  def confirmation_pending
    
  end
  
end
