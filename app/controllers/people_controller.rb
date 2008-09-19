class PeopleController < ApplicationController

  before_filter :logged_in, :only  => [ :show ]

  def index
    save_navi_state(['people', 'browse_people'])
  end
  
  def home
    if @current_user
      if params[:id] && !params[:id].eql?(@current_user.id)
        @title = :no_rights_to_view
      else
        save_navi_state(['own', 'home'])
        @title = :home
      end  
    else
      redirect_to(listings_path)
    end    
  end
  
  def show
    if @current_user
      @person = Person.find(params[:id])
      save_navi_state(['own', 'profile']) if session[:navi1].eql?("own")
      @title = @person.id 
    else
      @title = :only_logged_in_can_view
    end    
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
