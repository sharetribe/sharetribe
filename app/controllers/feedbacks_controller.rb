class FeedbacksController < ApplicationController

  skip_filter :check_email_confirmation
  skip_filter :dashboard_only
  skip_filter :cannot_access_without_joining

  def new
    ensure_confirmed_admin_email!
    @feedback = Feedback.new
  end

  def create
    ensure_confirmed_admin_email!
    @feedback = Feedback.new(params[:feedback].except(:title))

    # Detect most usual spam messages
    if (@feedback.content && (@feedback.content.include?("[url=") || @feedback.content.include?("<a href=")) || params[:feedback][:title].present? || @feedback.content.scan("http://").count > 10)
      flash[:error] = t("layouts.notifications.feedback_considered_spam")
      render :action => :new and return
    elsif @feedback.save
      flash[:notice] = t("layouts.notifications.feedback_saved")
      PersonMailer.new_feedback(@feedback, @current_community).deliver
    else
      flash[:error] = t("layouts.notifications.feedback_not_saved")
      render :action => :new and return
    end
    respond_to do |format|
      format.html { redirect_to root }
    end
  end

  private

  def ensure_confirmed_admin_email!
    unless confirmed_admin_emails?
      flash[:error] = t("layouts.notifications.no_confirmed_admin_email");
      redirect_to_back
    end
  end

  def confirmed_admin_emails?
    @current_community.admin_emails.length > 0
  end

  # Redirect to previous page (back) or root, if no previous page,
  # e.g. page accessed with direct URL
  def redirect_to_back
    redirect_to(request.env['HTTP_REFERER'] || root_path)
  end
end
