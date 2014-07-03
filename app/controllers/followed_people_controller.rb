class FollowedPeopleController < ApplicationController
  
  skip_before_filter :dashboard_only
  
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end
  
  def index
    @person = Person.find_by_id(params[:person_id])
    @followed_people = @person.followed_people
    respond_to do |format|
      format.js { render :partial => "people/followed_person", :collection => @followed_people, :as => :person }
    end
  end
  
  # Add or remove followed people from FollowersController
  
end

