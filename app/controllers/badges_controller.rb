include BadgesHelper

class BadgesController < ApplicationController

  before_filter :person_belongs_to_current_community
  skip_filter :dashboard_only

  def index
    redirect_to @person
  end

  def show
    @show_badge_status = true
    @badge = Badge.find_by_person_id_and_name(@person.id, params[:id])
    respond_to do |format|
      format.html {render :file => "public/404.html", :layout => false and return }
      format.js { render :layout => false }
    end
  end

end
