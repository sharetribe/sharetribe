class ContactsController < ApplicationController
  
  def index
    @title = "contacts"
    @person = Person.find(params[:person_id])
    save_navi_state(['own', 'contacts']) if current_user?(@person)
    session[:links_panel_navi] = 'contacts'
    @contacts = @person.contacts.paginate :page => params[:page], :per_page => per_page
  end

end
