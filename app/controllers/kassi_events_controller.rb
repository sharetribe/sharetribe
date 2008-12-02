class KassiEventsController < ApplicationController

  def index
    session[:profile_navi] = 'kassi_events'
    @person = Person.find(params[:person_id])
  end
  
end
