class ContactsController < ApplicationController
  def index
    save_navi_state(['own', 'profile', '', '', 'contacts'])
    @person = Person.find(params[:person_id])
  end

  def add
  end

end
