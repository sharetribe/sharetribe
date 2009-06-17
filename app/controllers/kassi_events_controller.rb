class KassiEventsController < ApplicationController

  before_filter :logged_in

  def index
    @person = Person.find(params[:person_id])
    session[:links_panel_navi] = 'kassi_events'
    save_navi_state(['own', 'kassi_events']) if current_user?(@person)
    @kassi_events = @person.kassi_events.paginate :page => params[:page], 
                                                  :per_page => per_page, 
                                                  :order => 'id DESC'
    @pagination_type = "kassi_events" 
  end
  
end
