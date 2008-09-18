class PeopleController < ApplicationController

  
  def index
    save_navi_state(['people', 'browse_people'])
  end
  
  def search
    save_navi_state(['people', 'search_people'])
  end

  def create
    # Open a Session first only for Kassi to be able to create a user
    @session = Session.create
    session[:cookie] = @session.headers["Cookie"]
    
    @person = Person.create(params[:person], session[:cookie])
    session[:person_id] = @person.id
    redirect_to(root_path) #TODO should redirect to the page where user was
  end
  
  def new
    @person = Person.new
  end
  
end
