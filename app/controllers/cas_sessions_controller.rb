require 'casclient'
require 'casclient/frameworks/rails/filter'

class CasSessionsController < ApplicationController

  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new]

  def create

    service_uri = COS_URL
    #logger.info "SESSION INCLUDES: " + session.inspect
    proxy_granting_ticket = session[:cas_pgt]
    #logger.info "PGT: " + proxy_granting_ticket.inspect
   # begin
      pt_ticket = CASClient::Frameworks::Rails::Filter.client.request_proxy_ticket(proxy_granting_ticket, service_uri).ticket
      #logger.info "PT_TICKET: " + pt_ticket.inspect
    #rescue RuntimeError => redirection #Note: it might be that 303 is not creating an exception (301,302 should)
    #      # Read the redirection target
    #      redirection_uri = JSON.parse(redirection.response.body)["redirect"]["uri"]
    #      
    #      #modify the redirection URI
    #      
    #      
    #      #Send the user to the requested page with correct url
    #      redirect_to redirection_uri
    #end
    
    # begin
#     @session = Session.create({ :username => params[:username], 
#                               :password => params[:password] })
      @session = CasSession.create({ :username => session[:cas_user], 
                                     :password => pt_ticket })
    # rescue Exception => redirection 
    #   # TODO: replace generic Error with more specific one ^
    #   
    #   # Read the redirection target
    #   redirection_uri = JSON.parse(redirection.response.body)["redirect"]["uri"]
    #   
    #   #modify the redirection URI
    #   succesfull_return_uri = "http://#{request.host}/cas_session"
    #   # FIXME: change to more appropriate fallback address with message
    #   fallback_uri = "http://#{request.host}/cas_session?login_failed=true"
    #   redirection_uri += "&redirect=#{succesfull_return_uri}&fallback=#{fallback_uri}"
    #   
    #   #Send the user to the requested page with correct url
    #   redirect_to redirection_uri
    # end
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
    unless params["login_failed"]
      redirect_to  :action => :new 
    else
      flash[:error] = :linking_accounts_failed
      redirect_to :root_path
    end
  end
end
