class Admin::FeedbacksController < ApplicationController
  
  skip_filter :check_email_confirmation
  
  protect_from_forgery :except => :create
  
  def create
    @feedback = Feedback.new(params[:feedback].except(:title))
    error_page = params[:feedback][:url].include?("Error page")
    # Detect most usual spam messages
    if (@feedback.content && (@feedback.content.include?("[url=") || @feedback.content.include?("<a href=")) || params[:feedback][:title].present?)
      if error_page
        flash[:error] = "feedback_considered_spam"
      else  
        flash.now[:error] = "feedback_considered_spam"
      end  
    elsif @feedback.save
      if error_page
        flash[:notice] = "feedback_saved"
      else  
        flash.now[:notice] = "feedback_saved"
      end
      PersonMailer.new_feedback(@feedback, @current_community).deliver
    else
      if error_page
        flash[:error] = "feedback_not_saved"
      else  
        flash.now[:error] = "feedback_not_saved"
      end
    end
    respond_to do |format|
      format.html { redirect_to (error_page ? root : params[:feedback][:url]) }
      format.js { render :layout => false }
    end
  end
  
end
