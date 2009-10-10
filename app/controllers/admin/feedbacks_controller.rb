class Admin::FeedbacksController < ApplicationController

  before_filter :is_admin, :except => :create
  protect_from_forgery :except => :create
  
  def index
    save_navi_state(['admin','','',''])
    @feedbacks = Feedback.paginate :page => params[:page], 
                                   :per_page => per_page,
                                   :order => "is_handled, id DESC"                               
  end

  def create
    # Commented because of spam
    # @feedback = Feedback.new(params[:feedback])
    # if @feedback.save
    #   flash[:notice] = :feedback_saved
    #   if RAILS_ENV != "development" 
    #     UserMailer.deliver_notification_of_new_feedback(@feedback, request)
    #   end
    # else
    #   flash[:error] = :feedback_not_saved
    # end
    redirect_to params[:feedback][:url]    
  end
  
  # Marks checked feedback fields as read
  def handle
    @feedback = Feedback.find(params[:id])
    @feedback.update_attribute(:is_handled, 1)
    redirect_to :back
  end

end
