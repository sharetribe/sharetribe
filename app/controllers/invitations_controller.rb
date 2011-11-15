class InvitationsController < ApplicationController
  
  def create
    @invitation = Invitation.new(params[:invitation])
    if @invitation.save
      notice = [:notice, "invitation_sent"]
      Delayed::Job.enqueue(InvitationCreatedJob.new(@invitation.id, request.host))
    else
      notice = [:error, "invitation_could_not_be_sent"]
    end
    respond_to do |format|
      format.html { 
        flash[notice[0]] = notice[1]
        redirect_to root 
      }
      format.js {
        flash.now[notice[0]] = notice[1]
        render :layout => false 
      }
    end
  end
  
end