class KassiEventsController < ApplicationController

  before_filter :logged_in

  def index
    @person = Person.find(params[:person_id])
    session[:links_panel_navi] = 'kassi_events'
    save_navi_state(['own', 'profile']) if current_user?(@person)
    @pagination_type = "kassi_events"
    @kassi_events = current_user?(@person) ? @person.own_kassi_events : @person.kassi_events
    @kassi_events = @kassi_events.paginate :page => params[:page], 
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
    logger.info "Doing stuff here"
    @kassi_event = KassiEvent.find(params[:id])
    params[:kassi_event][:pending] = 0
    @kassi_event.update_attributes(params[:kassi_event])
    other_party = @kassi_event.get_other_party(@current_user)
    if other_party.settings.email_when_new_comment_to_kassi_event == 1
      UserMailer.deliver_notification_of_new_comment_to_kassi_event(other_party, @kassi_event, request)
    end  
    flash[:notice] = :feedback_sent
    redirect_to person_kassi_events_path(Person.find(params[:person_id]))
  end
  
end
