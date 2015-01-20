class FollowedPeopleController < ApplicationController

  def index
    @person = Person.find(params[:person_id] || params[:id])
    PersonHelper.ensure_person_belongs_to_community!(@person, @current_community)

    @followed_people = @person.followed_people
    respond_to do |format|
      format.js { render :partial => "people/followed_person", :collection => @followed_people, :as => :person }
    end
  end

  # Add or remove followed people from FollowersController

end

