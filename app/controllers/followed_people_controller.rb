class FollowedPeopleController < ApplicationController

  def index
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)

    respond_to do |format|
      format.js { render partial: "people/followed_person", collection: target_user.followed_people, as: :person }
    end
  end
end

