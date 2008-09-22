class FriendsController < ApplicationController
  
  def index
    save_navi_state(['own', 'profile', '', '', 'friends'])
    @person = Person.find(params[:person_id])
  end

  def add
  end

end
