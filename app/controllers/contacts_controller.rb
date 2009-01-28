class ContactsController < ApplicationController
  
  def index
    @title = "contacts"
    @person = Person.find(params[:person_id])
    save_navi_state(['own', 'contacts']) if current_user?(@person)
    session[:profile_navi] = 'contacts'
    @contacts = Array.new
    @person.kassi_events.each do |kassi_event|
      kassi_event.people.each do |person|
        @contacts << person unless person.id == @person.id
      end
    end    
    @contacts = @contacts.uniq.paginate :page => params[:page], :per_page => per_page
  end

end
