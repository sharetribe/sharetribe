class PeopleController < ApplicationController

  def index
    save_navi_state(['people', 'listings', 'all'])
  end
  
  def show
    save_navi_state(['people', 'listings', 'all'])
  end
  
  def login
    session[:person_id] = 1
    clear_navi_state
  end 
  
  def logout
    session[:person_id] = nil
    clear_navi_state
  end

end
