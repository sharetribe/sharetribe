class FollowersController < ApplicationController
  
  skip_before_filter :dashboard_only
  
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end
  
  before_filter :person_belongs_to_current_community
  
  def create
    @person.followers << @current_user
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :partial => "people/follow_button", :locals => { :person => @person } }
    end
  end
  
  def destroy
    @person.followers.delete(@current_user)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :partial => "people/follow_button", :locals => { :person => @person } }
    end
  end
  
end

