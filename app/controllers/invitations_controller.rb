class InvitationsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_invite_new_user")
  end

  before_filter :users_can_invite_new_users

  def new
    @selected_tribe_navi_tab = "members"
    @invitation = Invitation.new
    invitation_limit = @current_community.join_with_invite_only ? Invitation.invite_only_invitation_limit : Invitation.invitation_limit

    onboarding_popup_locals = OnboardingViewUtils.popup_locals(
      flash[:show_onboarding_popup],
      admin_getting_started_guide_path,
      Admin::OnboardingWizard.new(@current_community.id).setup_status)

    view_locals = {
      invitation_limit: invitation_limit,
      has_admin_rights: @current_user.has_admin_rights?
    }

    render locals: onboarding_popup_locals.merge(view_locals)
  end

  def create
    invitation_params = params.require(:invitation).permit(
      :email,
      :message
    )

    invitation_emails = invitation_params[:email].split(",").map(&:strip)

    unless validate_daily_limit(@current_user.id, invitation_emails.size, @current_community)
      return redirect_to new_invitation_path, flash: { error: t("layouts.notifications.invitation_limit_reached")}
    end

    sending_problems = nil
    invitation_emails.each do |email|
      invitation = Invitation.new(
        message: invitation_params[:message],
        email: email,
        inviter: @current_user,
        community_id: @current_community.id
      )

      if invitation.save
        Delayed::Job.enqueue(InvitationCreatedJob.new(invitation.id, @current_community.id))

        # Onboarding wizard step recording
        state_changed = Admin::OnboardingWizard.new(@current_community.id)
          .update_from_event(:invitation_created, invitation)
        if state_changed
          report_to_gtm({event: "km_record", km_event: "Onboarding invitation created"})

          with_feature(:onboarding_redesign_v1) do
            flash[:show_onboarding_popup] = true
          end
        end
      else
        sending_problems = true
      end
    end

    if sending_problems
      flash[:error] = t("layouts.notifications.invitation_cannot_be_sent")
    else
      flash[:notice] = t("layouts.notifications.invitation_sent")
    end

    redirect_to new_invitation_path
  end

  private

  def users_can_invite_new_users
    unless @current_community.allows_user_to_send_invitations?(@current_user)
      flash[:error] = t("layouts.notifications.inviting_new_users_is_not_allowed_in_this_community")
      redirect_to search_path and return
    end
  end

  def validate_daily_limit(inviter_id, number_of_emails, community)
    email_count = (number_of_emails + daily_email_count(inviter_id))
    email_count < Invitation.invitation_limit || (community.join_with_invite_only && email_count < Invitation.invite_only_invitation_limit)
  end

  def daily_email_count(inviter_id)
    Invitation.where(inviter_id: inviter_id, created_at: 1.day.ago..Time.now).count
  end

end
