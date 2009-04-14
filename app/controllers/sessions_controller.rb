class SessionsController < ApplicationController
  def create
    begin
      @session = Session.create({ :username => params[:username], 
                                  :password => params[:password] })
    rescue ActiveResource::UnauthorizedAccess => e
      flash[:error] = :login_failed
      redirect_to new_session_path and return
    end
    
    if @session.person_id  # if not app-only-session and person found in cos
      unless  @current_user = Person.find_by_id(@session.person_id)
        # The user has succesfully logged in, but is not found in Kassi DB
        # Existing Sizzle user's first login in Kassi
        session[:temp_cookie] = @session.headers["Cookie"]
        session[:temp_person_id] = @session.person_id
        
        #@current_user = Person.add_to_kassi_db(@session.person_id )
        redirect_to consent_path() and return
        
      end
    end
    
    session[:cookie] = @session.headers["Cookie"]
    session[:person_id] = @session.person_id
  
    #self.smerf_user_id = @session.person_id
      
    flash[:notice] = :login_successful
    if session[:return_to]
      redirect_to session[:return_to]
      session[:return_to] = nil
    else
      redirect_to root_path
    end
  end
  
  def destroy
    Session.destroy(session[:cookie]) if session[:cookie]
    session[:cookie] = nil
    session[:person_id] = nil
    flash[:notice] = :logout_successful
    redirect_to(root_path)
  end
  
  def new
    # TODO: this clearence of navi state causes problems, when returning somewhere
    # there is no navi. Should store the navi state or do something else...
    # clear_navi_state
    @session =  Session.new
  end
end
