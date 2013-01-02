class FeedbacksController < ApplicationController
  
  skip_filter :check_email_confirmation
  skip_filter :not_public_in_private_community, :only => [ :create ]
  skip_filter :dashboard_only
  
  layout "feedback"
  
  def new
    @feedback = Feedback.new  
  end
  
  def create
    @feedback = Feedback.new(params[:feedback].except(:title))
    error_page = params[:feedback][:url].include?("Error page")
    # Detect most usual spam messages
    if (@feedback.content && (@feedback.content.include?("[url=") || @feedback.content.include?("<a href=")) || params[:feedback][:title].present? || @feedback.content.scan("http://").count > 10)
      flash[:error] = t("layouts.notifications.feedback_considered_spam")
    elsif @feedback.save
      flash[:notice] = t("layouts.notifications.feedback_saved")
      PersonMailer.new_feedback(@feedback, @current_community).deliver
    else
      flash[:error] = t("layouts.notifications.feedback_not_saved")
    end
    respond_to do |format|
      format.html { redirect_to root }
    end 
  end
  
end
