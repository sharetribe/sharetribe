include BadgesHelper

class BadgesController < ApplicationController

  def index
    @person = Person.find(params[:person_id])
    redirect_to person_testimonials_path(:person_id => @person.id) unless @person.badges_visible_to?(@current_user)
    @badges = possible_badges_visible_to?(@current_user) ? Badge::UNIQUE_BADGES : @person.badges.collect(&:name)
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