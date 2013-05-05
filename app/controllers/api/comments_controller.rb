class Api::CommentsController < Api::ApiController

  before_filter :authenticate_person!
  before_filter :ensure_authorized_to_view_listing

  def create      
    @comment = Comment.new(:content => params[:content], :listing_id => params[:listing_id], :author_id => current_person.id)

    if @comment.save
      response.status = :created
      Delayed::Job.enqueue(CommentCreatedJob.new(@comment.id, @current_community.id))
      respond_with @comment
    else
      response.status = 400
      render :json => [@comment.errors.full_messages] and return
    end
  end


end
