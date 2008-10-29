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
  
  # Shows profile page of a person.
  def show
    @person = Person.find(params[:id])
    @items = Item.find(:all, :conditions => "owner_id = '" + @person.id.to_s + "'")
    @item = Item.new
    @favors = Favor.find(:all, :conditions => "owner_id = '" + @person.id.to_s + "'")
    @favor = Favor.new
    if @person.id == @current_user.id
      save_navi_state(['own', 'profile', '', '', 'information'])
    else
      session[:profile_navi] = 'information'
    end     
    @title = @person.name(session[:cookie]) 
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
    if RAILS_ENV == "production"
      render :template => "people/beta"
    end
    @person = Person.new
  end
  
  def send_message
    @person = Person.find(params[:id])
    @message = Message.new
  end
  
end
