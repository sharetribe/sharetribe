class FollowersController < ApplicationController

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end

  def create
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)

    target_user.followers << @current_user
    respond_to do |format|
      format.html { redirect_back(fallback_location: homepage_url) }
      format.js { render :partial => "people/follow_button", :locals => { :person => target_user } }
    end
  end

  def destroy
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)

    target_user.followers.delete(@current_user)
    respond_to do |format|
      format.html { redirect_back(fallback_location: homepage_url) }
      format.js { render :partial => "people/follow_button", :locals => { :person => target_user } }
    end
  end

end

