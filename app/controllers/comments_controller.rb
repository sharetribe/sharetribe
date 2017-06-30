class CommentsController < ApplicationController

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_comment")
  end

  before_action :ensure_authorized_to_comment, only: [:create]

  def create
    if @comment.save
      @comment.reload # reload is needed, as create.js.erb refers the model directly
      Delayed::Job.enqueue(CommentCreatedJob.new(@comment.id, @current_community.id))
    else
      flash[:error] = t("layouts.notifications.comment_cannot_be_empty")
    end
    respond_to do |format|
      format.html { redirect_to listing_path(params[:comment][:listing_id]) }
      format.js { render :layout => false }
    end
  end

  def destroy
    @comment = @current_community.listings.find(params[:listing_id]).comments.find(params[:id])
    if current_user?(@comment.author) || @current_user.has_admin_rights?(@current_community)
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to listing_path(params[:listing_id]) }
        format.js { render :layout => false }
      end
    else
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_do_this")
      redirect_to listing_path(params[:listing_id])
    end
  end

  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_comment
    @comment = initialize_comment(
      params,
      author_id: @current_user.id,
      community_id: @current_community.id
    )

    unless @comment.listing.visible_to?(@current_user, @current_community)
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      redirect_to search_path and return
    end
  end

  def initialize_comment(params, opts)
    comment_params = params.require(:comment).permit(
      :content,
      :author_follow_status,
      :listing_id,
    ).merge(opts)

    Comment.new(comment_params)
  end
end
