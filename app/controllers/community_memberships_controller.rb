class CommunityMembershipsController < ApplicationController
  
  def new
    @community_membership = CommunityMembership.new
    logger.info "Current user from controller: #{@current_user}"
  end
  
  def create
    @community_membership = CommunityMembership.new(params[:community_membership])
    if @community_membership.save
      redirect_to root_path
    else
      render :action => :new
    end
  end
  
end