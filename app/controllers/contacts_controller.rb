class ContactsController < ApplicationController
  def index
    if @person.equal?(@current_user)  
      save_navi_state(['own', 'profile', '', '', 'contacts'])
    else
      session[:profile_navi] = 'contacts'
    end
    @person = Person.find(params[:person_id])
  end

  def add
  end

end
