require 'rest_client'

class SessionsController < ApplicationController
  
  def create
    session[:form_username] = params[:username]
    begin
      @session = Session.create({ :username => params[:username], 
                                  :password => params[:password] })
                                                          
    rescue RestClient::Unauthorized => e
      flash[:error] = :login_failed
      redirect_to login_path and return
    end

    session[:form_username] = nil
    
    if @session.person_id  # if not app-only-session and person found in cos
      unless  @current_user = Person.find_by_id(@session.person_id)
        # The user has succesfully logged in, but is not found in Kassi DB
        # Existing Sizzle user's first login in Kassi
        session[:temp_cookie] = @session.cookie
        session[:temp_person_id] = @session.person_id
        redirect_to terms_path and return
      end
    end
    
    session[:cookie] = @session.cookie
    session[:person_id] = @session.person_id
      
    flash[:notice] = [:login_successful, (@current_user.given_name + "!").to_s, person_path(@current_user)]
    if session[:return_to]
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
      redirect_to root
    end
  end
  
  def destroy
    Session.destroy(session[:cookie]) if session[:cookie]
    session[:cookie] = nil
    session[:person_id] = nil
    flash[:notice] = :logout_successful
    redirect_to root
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
  
end
