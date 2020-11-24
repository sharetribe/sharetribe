class InvitationsController < ApplicationController

  before_action except: :unsubscribe do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_invite_new_users")
  end

  before_action :users_can_invite_new_users, except: :unsubscribe

  def new
    @selected_tribe_navi_tab = "members"
    @invitation = Invitation.new
    invitation_limit = @current_community.join_with_invite_only ? Invitation.invite_only_invitation_limit : Invitation.invitation_limit

    make_onboarding_popup
    view_locals = {
      invitation_limit: invitation_limit,
      has_admin_rights: @current_user.has_admin_rights?(@current_community)
    }

    render locals: view_locals
  end

  def create
    invitation_params = params.require(:invitation).permit(
      :email,
      :message
    )

    raw_invitation_emails = invitation_params[:email].split(",").map(&:strip)
    invitation_emails = Invitation::Unsubscribe.remove_unsubscribed_emails(@current_community, raw_invitation_emails)

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
          record_event(flash, "km_record", {km_event: "Onboarding invitation created"}, AnalyticService::EVENT_USER_INVITED)

          flash[:show_onboarding_popup] = true
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

  def unsubscribe
    invitation_unsubscribe = Invitation::Unsubscribe.unsubscribe(params[:code])
    if invitation_unsubscribe.persisted?
      flash[:notice] = t("layouts.notifications.invitation_successfully_unsubscribed")
    else
      flash[:error] = t("layouts.notifications.invitation_cannot_unsubscribe")
    end
    redirect_to landing_page_path
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
