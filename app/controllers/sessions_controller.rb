class SessionsController < ApplicationController
  def create
    @session = Session.create({ :username => params[:username], 
                               :password => params[:password] })
    session[:cookie] = @session.headers["Cookie"]
    session[:person_id] = @session.person_id 
  end
  
  def destroy
    Session.destroy(session[:cookie]) if session[:cookie]
    session[:cookie] = nil
    session[:person_id] = nil
    redirect_to(root_path)
  end
  
  def new
    @session =  Session.new
  end
end
