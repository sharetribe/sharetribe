class KassiEventsController < ApplicationController

  def index
    session[:profile_navi] = 'kassi_events'
    save_navi_state(['own', 'kassi_events', '', '', 'kassi_events']) if session[:navi1] == 'own'
    @person = Person.find(params[:person_id])
    @kassi_events = @person.kassi_events.paginate :page => params[:page], 
                                                  :per_page => per_page, 
                                                  :order => 'id DESC'
    @pagination_type = "kassi_events" 
  end
  
end
