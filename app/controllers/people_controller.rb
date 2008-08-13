class PeopleController < ApplicationController
  
  def login
    session[:person_id] = 1
    clear_navi_state
  end 
  
  def logout
    session[:person_id] = nil
    clear_navi_state
  end

end
