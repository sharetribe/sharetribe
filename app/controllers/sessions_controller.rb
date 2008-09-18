class SessionsController < ApplicationController
  def create
    @session = Session.create({ :username => params[:username], 
                               :password => params[:password] })
    session[:cookie] = @session.headers["Cookie"]
    session[:person_id] = @session.person_id
    unless  @current_user = Person.find_by_id(session[:person_id])
      # The user has succesfully logged in, but is not found in Kassi DB
      #@current_user = Person.add_to_kassi_db(@session.person_id)
    end
    flash[:notice] = :login_succesful
    redirect_to(root_path) #TODO should redirect to the page where user was
  end
  
  def destroy
    Session.destroy(session[:cookie]) if session[:cookie]
    session[:cookie] = nil
    session[:person_id] = nil
    flash[:notice] = :logout_succesful
    redirect_to(root_path)
  end
  
  def new
    @session =  Session.new
  end
end
