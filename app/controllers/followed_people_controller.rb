class FollowedPeopleController < ApplicationController
  
  skip_before_filter :dashboard_only
  
  before_filter :person_belongs_to_current_community
  
  def index
    @followed_people = @person.followed_people
    respond_to do |format|
      format.js { render :partial => "people/followed_person", :collection => @followed_people, :as => :person }
    end
  end
  
  # Add or remove followed people from FollowersController
  
end

