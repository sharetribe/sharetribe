class CommentsController < ApplicationController
  
  before_filter do |controller|
    controller.ensure_logged_in "you_must_log_in_to_send_a_comment"
  end
  
  def create
    @comment = Comment.new(params[:comment])
    if @comment.save
      flash.now[:comment_notice] = "comment_sent"
      @comment.send_email_to_author(request.host)
    else
      flash[:error] = "comment_cannot_be_empty"
    end
    respond_to do |format|
      format.html { redirect_to listing_path(params[:comment][:listing_id]) }
      format.js { render :layout => false }
    end
  end
end
