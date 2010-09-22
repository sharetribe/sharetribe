class Admin::FeedbacksController < ApplicationController
  
  def create
    @feedback = Feedback.new(params[:feedback])
    # Detect most usual spam messages
    if (@feedback.content && @feedback.content.include?("[url="))
      flash.now[:error] = "feedback_considered_spam"
    elsif @feedback.save
      flash.now[:notice] = "feedback_saved"
      #PersonMailer.deliver_notification_of_new_feedback(@feedback, request)
    else
      flash.now[:error] = "feedback_not_saved"
    end
    respond_to do |format|
      format.html { redirect_to params[:feedback][:url] }
      format.js { render :layout => false }
    end
  end
  
end
