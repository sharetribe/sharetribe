class ContactsController < ApplicationController
  
  def index
    save_navi_state(['own', 'contacts'])
    @title = "contacts"
    if @person.equal?(@current_user)  
      save_navi_state(['own', 'profile', '', '', 'contacts'])
    else
      session[:profile_navi] = 'contacts'
    end
    @person = Person.find(params[:person_id])
    @contacts = Array.new
    @person.kassi_events.each do |kassi_event|
      kassi_event.people.each do |person|
        @contacts << person unless person.id == @person.id
      end
    end    
    @contacts = @contacts.uniq.paginate :page => params[:page], :per_page => per_page
  end

end
