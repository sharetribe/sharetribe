class InvitationsController < ApplicationController
  
  skip_filter :dashboard_only
  
  before_filter :only => :create do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_invite_new_user")
  end
  
  before_filter :users_can_invite_new_users, :only => :create
  
  def create
    @invitation = Invitation.new(params[:invitation])
    if @invitation.save
      flash[:notice] = t("layouts.notifications.invitation_sent")
      Delayed::Job.enqueue(InvitationCreatedJob.new(@invitation.id, request.host))
    else
      flash[:error] = t("layouts.notifications.invitation_could_not_be_sent")
    end
    respond_to do |format|
      format.html {
        redirect_to root 
      }
      format.js {
        render :layout => false 
      }
    end
  end
  
  private
  
  def users_can_invite_new_users
    unless @current_community.users_can_invite_new_users || @current_user.has_admin_rights_in?(@current_community)
      flash[:error] = t("layouts.notifications.inviting_new_users_is_not_allowed_in_this_community")
      redirect_to root and return
    end
  end
  
end