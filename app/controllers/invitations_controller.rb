class InvitationsController < ApplicationController

  skip_filter :dashboard_only

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_invite_new_user")
  end

  before_filter :users_can_invite_new_users

  def new
    @selected_tribe_navi_tab = "members"
    @invitation = Invitation.new
  end

  def create
    invitation_emails = params[:invitation][:email].split(",")
    sending_problems = nil

    invitation_emails.each do |email|
      invitation = Invitation.new(params[:invitation].merge!({:email => email.strip, :inviter => @current_user}))
      if invitation.save
        Delayed::Job.enqueue(InvitationCreatedJob.new(invitation.id, request.host))
      else
        sending_problems = true
      end
    end

    if sending_problems
      flash[:error] = t("layouts.notifications.invitation_could_not_be_sent")
    else
      flash[:notice] = t("layouts.notifications.invitation_sent")
    end

    redirect_to new_invitation_path
  end

  private

  def users_can_invite_new_users
    unless @current_community.allows_user_to_send_invitations?(@current_user)
      flash[:error] = t("layouts.notifications.inviting_new_users_is_not_allowed_in_this_community")
      redirect_to root and return
    end
  end

end
