class FollowersController < ApplicationController
  
  skip_before_filter :dashboard_only
  
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end
  
  def create
    Person.find(params[:person_id]).followers << @current_user
    redirect_to :back
  end
  
  def destroy
    Person.find(params[:person_id]).followers.delete(@current_user)
    redirect_to :back
  end
  
end

