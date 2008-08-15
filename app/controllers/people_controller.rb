class PeopleController < ApplicationController
  
  def index
    save_navi_state(['people', 'browse_people'])
  end
  
  def search
    save_navi_state(['people', 'search_people'])
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
