class CommunityMembershipsController < ApplicationController
  
  before_filter do |controller|
    controller.ensure_logged_in("you_must_log_in_to_view_this_page")
  end
  
  def new
    if @current_user.communities.include?(@current_community)
      flash[:notice] = "you_are_already_member"
      redirect_to root 
    end
    @community_membership = CommunityMembership.new
  end
  
  def create
    @community_membership = CommunityMembership.new(params[:community_membership])
    if @community_membership.save
      Delayed::Job.enqueue(CommunityJoinedJob.new(@current_user.id, @current_community.id))
      flash[:notice] = "you_are_now_member"
      redirect_to root 
    else
      flash[:error] = "joining_community_failed"
      render :action => :new
    end
  end
  
end