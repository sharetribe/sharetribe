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
    
    
    # This is reached only if requirements are fulfilled
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