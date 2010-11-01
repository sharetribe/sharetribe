class BadgesController < ApplicationController

  def index
    @person = Person.find(params[:person_id])
  end
  
  def show
    @person = Person.find(params[:person_id])
    @show_badge_status = true
    @badge = Badge.find_by_person_id_and_name(@person.id, params[:id])
    respond_to do |format|
      format.html { }
      format.js { render :layout => false }
    end
  end
   
end