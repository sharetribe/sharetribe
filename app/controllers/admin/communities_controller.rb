class Admin::CommunitiesController < ApplicationController
  
  include CommunitiesHelper
  
  before_filter :ensure_is_admin
  
  skip_filter :dashboard_only
  
  def edit_details
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "tribe_details"
    @community = @current_community
  end
  
  def edit_look_and_feel
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "tribe_look_and_feel"
    @community = @current_community
  end
  
  def update
    return_to_action =  (params[:community_settings_page] == "look_and_feel" ? :edit_look_and_feel : :edit_details)
    
    @community = Community.find(params[:id])
    need_to_regenerate_css = params[:community][:custom_color1] != @community.custom_color1 || params[:community][:cover_photo]
    
    params[:community][:join_with_invite_only] = params[:community][:join_with_invite_only].present?
    params[:community][:custom_color1] = nil if params[:community][:custom_color1] == ""
    
    if @community.update_attributes(params[:community])
      flash[:notice] = t("layouts.notifications.community_updated")
      @community.generate_customization_stylesheet if need_to_regenerate_css
      redirect_to (return_to_action == :edit_look_and_feel ? 
                   edit_look_and_feel_admin_community_path(@community) : 
                   edit_details_admin_community_path(@community))  
    else
      flash.now[:error] = t("layouts.notifications.community_update_failed")
      render :action => return_to_action  
    end
  end
  
end