class Admin::FeedbacksController < ApplicationController

  before_filter :is_admin, :only => :index
  protect_from_forgery :except => :create
  
  def index
    save_navi_state(['admin','','',''])
    @feedbacks = Feedback.paginate :page => params[:page], 
                                   :per_page => per_page,
                                   :order => "id DESC"
  end

  def create
    @feedback = Feedback.new(params[:feedback])
    if @feedback.save
      flash[:notice] = :feedback_saved
    else
      flash[:error] = :feedback_not_saved
    end
    redirect_to params[:feedback][:url]    
  end
  

end
