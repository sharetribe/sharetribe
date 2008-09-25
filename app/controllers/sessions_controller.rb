class SessionsController < ApplicationController
  def create
    @session = Session.create({ :username => params[:username], 
                               :password => params[:password] })
    session[:cookie] = @session.headers["Cookie"]
    session[:person_id] = @session.person_id
 
    if session[:person_id]  # if not app-only-session and person found in cos
      unless  @current_user = Person.find_by_id(session[:person_id])
        # The user has succesfully logged in, but is not found in Kassi DB
        @current_user = Person.add_to_kassi_db(@session.person_id )
      end
      #@current_user.cos_cookie = @session.headers["Cookie"]
      #@current_user.save
    end
     
    flash[:notice] = :login_succesful
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
    @current_user.cos_cookie = nil if @current_user
    session[:person_id] = nil
    flash[:notice] = :logout_succesful
    redirect_to(root_path)
  end
  
  def new
    @session =  Session.new
  end
end
