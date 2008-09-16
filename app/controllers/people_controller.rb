class PeopleController < ApplicationController

  
  def index
    save_navi_state(['people', 'browse_people'])
  end
  
  def search
    save_navi_state(['people', 'search_people'])
  end

  def create
    # Open a Session first only for Kassi to be able to create a user
    @session = Session.login
    session[:cookie] = @session.headers["Cookie"]
    
    @person = Person.create(params[:person], session[:cookie])
  end
  
  def new
    @person = Person.new({})
  end
  
end
