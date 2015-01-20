class FollowedPeopleController < ApplicationController

  def index
    @person = Person.find(params[:person_id] || params[:id])
    ensure_person_belongs_to_current_community!(@person)

    @followed_people = @person.followed_people
    respond_to do |format|
      format.js { render :partial => "people/followed_person", :collection => @followed_people, :as => :person }
    end
  end

  # Add or remove followed people from FollowersController

end

