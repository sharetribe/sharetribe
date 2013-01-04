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
    need_to_regenerate_css = params[:custom_color1] != @community.custom_color1 || params[:cover_photo]
    params[:community][:join_with_invite_only] = params[:community][:join_with_invite_only].present?
    
    if @community.update_attributes(params[:community])
      flash[:notice] = t("layouts.notifications.community_updated")
      @community.generate_customization_stylesheet if need_to_regenerate_css
      if params[:community_settings_page] == "look_and_feel"
        redirect_to edit_look_and_feel_admin_community_path(@community)
      else
        redirect_to edit_details_admin_community_path(@community)   
      end
    else
      flash[:error] = t("layouts.notifications.community_update_failed")
      render :action => :edit_details
    end
  end
  
end