class SessionsController < ApplicationController
  def create
    @session = Session.login({ :username => params[:username], 
                               :password => params[:password] })
    session[:cookie] = @session.headers["Cookie"] 
  end
  
  def destroy
    Session.destroy(session[:cookie])
    session[:cookie] = nil
  end
end
