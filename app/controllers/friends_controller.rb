class FriendsController < ApplicationController
  
  def index
    if @person.equal?(@current_user)  
      save_navi_state(['own', 'profile', '', '', 'friends'])
    else
      session[:profile_navi] = 'friends'
    end
    @person = Person.find(params[:person_id])
  end

  def add
  end

end
