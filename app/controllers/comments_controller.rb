class CommentsController < ApplicationController
  
  before_filter do |controller|
    controller.ensure_logged_in "you_must_log_in_to_send_a_comment"
  end
  
  before_filter :ensure_authorized_to_comment
  
  def create
    if @comment.save
      flash.now[:comment_notice] = "comment_sent"
      logger.info "Comment amount: #{@comment.author.authored_comments.size}"
      Delayed::Job.enqueue(CommentCreatedJob.new(@comment.id, request.host))
    else
      flash[:error] = "comment_cannot_be_empty"
    end
    respond_to do |format|
      format.html { redirect_to listing_path(params[:comment][:listing_id]) }
      format.js { render :layout => false }
    end
  end
  
  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_comment
    @comment = Comment.new(params[:comment])
    unless @comment.listing.visible_to?(@current_user, @current_community)
      flash[:error] = "you_are_not_authorized_to_view_this_content"
      redirect_to root and return
    end  
  end
  
end
