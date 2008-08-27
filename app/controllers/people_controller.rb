class PeopleController < ApplicationController

  
  def index
    save_navi_state(['people', 'browse_people'])
  end
  
  def search
    save_navi_state(['people', 'search_people'])
  end

  def create
    @person = Person.create(params[:person], session[:cookie])
    # if ! @person.valid?
    #   render status :bad_request and return
    # end
  end
  
  def new
    
  end
  
end
