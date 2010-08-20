class PeopleController < ApplicationController
  
  def show
    @person = Person.find(params[:id])
  end

  def new
    @person = Person.new
  end

  def create
    # Open a Session first only for Kassi to be able to create a user
    @session = Session.create
    session[:cookie] = @session.cookie
    params[:person][:locale] = session[:locale] || 'fi'
    
    # Try to create a new person in ASI.
    @person = Person.new
    begin
      @person = Person.create(params[:person], session[:cookie])
    rescue RestClient::RequestFailed => e
      logger.info "Failed because of #{JSON.parse(e.response.body)["messages"]}"
      render :action => "new" and return
    end
    session[:person_id] = @person.id
    flash[:notice] = :registration_succeeded
    redirect_to (session[:return_to] || root)
  end

  def edit
  end
  
  def check_username_availability
    respond_to do |format|
      format.json { render :json => Person.username_available?(params[:person][:username]) }
    end
  end
  
  def check_email_availability
    respond_to do |format|
      format.json { render :json => Person.email_available?(params[:person][:email]) }
    end
  end

end
