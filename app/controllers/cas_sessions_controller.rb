require 'casclient'
require 'casclient/frameworks/rails/filter'

class CasSessionsController < ApplicationController

  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new]

  def create

    service_uri = APP_CONFIG.asi_url
    #logger.info "SESSION INCLUDES: " + session.inspect
    proxy_granting_ticket = session[:cas_pgt]
    #logger.info "PGT: " + proxy_granting_ticket.inspect

    pt_ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(proxy_granting_ticket, service_uri).ticket

    
    begin
      @session = CasSession.create({ :username => session[:cas_user], :password => pt_ticket })
    rescue CasSession::RedirectionException => redirection
      # Read the redirection target
      redirection_uri = redirection.message
      #modify the redirection URI
      succesfull_return_uri = "http://#{request.host}/cas_session?account_linked=true"
      fallback_uri = "http://#{request.host}/cas_session"
      redirection_uri += "&redirect=#{succesfull_return_uri}&fallback=#{fallback_uri}"
          
      #Send the user to the requested page with correct url
      redirect_to redirection_uri and return
    end
    
    session[:cookie] = @session.headers["Cookie"]
    session[:person_id] = @session.person_id
    
    if session[:person_id]  # if not app-only-session and person found in cos
      unless  @current_user = Person.find_by_id(session[:person_id])
        # The user has succesfully logged in, but is not found in Kassi DB
        @current_user = Person.add_to_kassi_db(@session.person_id )
      end
    end
     
    flash[:notice] = :login_successful
    if session[:return_to]
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
      redirect_to root_path
    end
  end
  
  def destroy
    CasSession.destroy(session[:cookie]) if session[:cookie]
    session[:cookie] = nil
    session[:person_id] = nil
    flash[:notice] = :logout_successful
    redirect_to(root_path)
  end
  
  def new
    # TODO: this clearence of navi state causes problems, when returning somewhere
    # there is no navi. Should store the navi state or do something else...

    #clear_navi_state
    @session =  CasSession.new
    #debugger
    self.create
  end
  
  def show 
    # This is actually used only as a return target after account linking in Asi
    # After the account linking is made we need to initate the session by trying to open CAS session again.
    if params["account_linked"]
      redirect_to :action => :new 
    else
      flash[:error] = :login_failed
      redirect_to root_path
    end
  end
end
