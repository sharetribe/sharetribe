class KassiEventsController < ApplicationController

  before_filter :logged_in

  def index
    @person = Person.find(params[:person_id])
    session[:links_panel_navi] = 'kassi_events'
    save_navi_state(['own', 'profile']) if current_user?(@person)
    @pagination_type = "kassi_events"
    @kassi_events = @person.kassi_events.paginate :page => params[:page], 
                                                  :per_page => per_page,
                                                  :order => "id DESC"
  end
  
  def show
    @person = Person.find(params[:person_id])
    session[:links_panel_navi] = 'kassi_events'
    save_navi_state(['own', 'profile']) if current_user?(@person)
    @pagination_type = "kassi_events"
    @kassi_events = [KassiEvent.find(params[:id])].paginate :page => params[:page], :per_page => per_page
    render :action => :index
  end
  
  # Used to add new comments to an existing Kassi event
  def update
    KassiEvent.find(params[:id]).update_attributes(params[:kassi_event])
    flash[:notice] = :feedback_sent
    redirect_to person_kassi_events_path(Person.find(params[:person_id]))
  end
  
end
