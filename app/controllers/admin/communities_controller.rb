class Admin::CommunitiesController < ApplicationController
  
  include CommunitiesHelper
  
  before_filter :ensure_is_admin
  
  skip_filter :dashboard_only
  
  def edit_details
    session[:selected_tab] = "admin"
    session[:selected_left_navi_link] = "tribe_details"
    @community = @current_community
  end
  
  def edit_look_and_feel
    session[:selected_tab] = "admin"
    session[:selected_left_navi_link] = "tribe_look_and_feel"
    @community = @current_community
  end
  
  def update
    @community = Community.find(params[:id])
    params[:community][:join_with_invite_only] = params[:community][:join_with_invite_only].present?
    if @community.update_attributes(params[:community])
      flash[:notice] = t("layouts.notifications.community_updated")
      redirect_to edit_details_admin_community_path(@community)   
    else
      flash[:error] = t("layouts.notifications.community_update_failed")
      render :action => :edit_details
    end
  end
  
end