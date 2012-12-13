class Admin::CommunitiesController < ApplicationController
  
  include CommunitiesHelper
  
  layout "layouts/admin"
  
  before_filter :ensure_is_admin
  
  skip_filter :dashboard_only
  
  def edit
    @community = @current_community
  end
  
  def update
    @community = Community.find(params[:id])
    params[:community][:join_with_invite_only] = params[:community][:join_with_invite_only].present?
    if @community.update_attributes(params[:community])
      flash[:notice] = "community_updated"
      redirect_to edit_admin_community_path(:type => "tribe_info")    
    else
      flash[:error] = "community_update_failed"
      render :action => :edit
    end
  end
  
end