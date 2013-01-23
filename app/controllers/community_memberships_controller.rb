class CommunityMembershipsController < ApplicationController
  
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_page")
  end
  
  skip_filter :dashboard_only
  skip_filter :single_community_only, :only => :create
  skip_filter :cannot_access_without_joining
  
  def new
    if @current_user.communities.include?(@current_community)
      flash[:notice] = t("layouts.notifications.you_are_already_member")
      redirect_to root 
    end
    @community_membership = CommunityMembership.new
  end
  
  def create
    @community_membership = CommunityMembership.new(params[:community_membership])
        
    if @current_community.join_with_invite_only? || params[:invitation_code]
      unless Invitation.code_usable?(params[:invitation_code], @current_community)
        # abort user creation if invitation is not usable. 
        # (This actually should not happen since the code is checked with javascript)
        # This could happen if invitation code is coming from hidden field and is wrong/used for some reason
        session[:invitation_code] = nil # reset code from session if there was issues so that's not used again
        ApplicationHelper.send_error_notification("Invitation code check did not prevent submiting form, but was detected in the CommunityMembershipsController", "Invitation code error")
        
        # TODO: if this ever happens, should change the message to something else than "unknown error"
        flash[:error] = t("layouts.notifications.unknown_error")
        render :action => :new and return
      else
        invitation = Invitation.find_by_code(params[:invitation_code].upcase)
      end
    end
    
    # If community requires certain email address and user doesn't have it confirmed.
    # Send confirmation for that.
    if @current_community.allowed_emails.present?
      
      unless @current_user.has_valid_email_for_community?(@current_community)
        
        # no confirmed allowed email found. Check if there is unconfirmed or should we add one.
        if @current_user.has_email?(params[:community_membership][:email])
          e = Email.find_by_address(params[:community_membership][:email])
        elsif 
          e = Email.create(:person => @current_user, :address => params[:community_membership][:email])
        end
        
        # Send confirmation
        PersonMailer.additional_email_confirmation(e, request.host_with_port).deliver
        e.confirmation_sent_at = Time.now
        e.save
        
        flash[:notice] = "#{t("layouts.notifications.you_need_to_confirm_your_account_first")} #{t("sessions.confirmation_pending.check_your_email")}."
        render :action => :new and return
      end
      
    end
    
    
    @community_membership.invitation = invitation if invitation.present?

    # This is reached only if requirements are fulfilled
    if @community_membership.save
      session[:fb_join] = nil
      session[:invitation_code] = nil
      # If invite was used, reduce usages left
      invitation.use_once! if invitation.present?
      
      Delayed::Job.enqueue(CommunityJoinedJob.new(@current_user.id, @current_community.id))
      flash[:notice] = t("layouts.notifications.you_are_now_member")
      redirect_to root 
    else
      flash[:error] = t("layouts.notifications.joining_community_failed")
      logger.info { "Joining a community failed, because: #{@community_membership.errors.full_messages}" }
      render :action => :new
    end
  end
  
end