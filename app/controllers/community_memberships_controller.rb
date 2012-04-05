class CommunityMembershipsController < ApplicationController
  
  before_filter do |controller|
    controller.ensure_logged_in("you_must_log_in_to_view_this_page")
  end
  
  def new
    @community_membership = CommunityMembership.new
  end
  
  def create
    @community_membership = CommunityMembership.new(params[:community_membership])
    if @community_membership.save
      flash[:notice] = "you_are_now_member"
      redirect_to root 
    else
      flash[:error] = "joining_community_failed"
      render :action => :new
    end
  end
  
end