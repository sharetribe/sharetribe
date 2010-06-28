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
    #logger.info "PT_TICKET: " + pt_ticket.inspect

#    @session = Session.create({ :username => params[:username], 
#                               :password => params[:password] })
    @session = CasSession.create({ :username => session[:cas_user],
                                :password => pt_ticket })
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
end
