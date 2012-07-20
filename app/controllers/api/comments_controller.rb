class Api::CommentsController < Api::ApiController

  before_filter :authenticate_person!

  def create
    @current_community = Community.find_by_id(params[:community_id])
    @listing = Listing.find_by_id(params[:listing_id])
    if @listing.nil?
      response.status = 404
      render :json => ["No listing found with given id"] and return
    end
    
    if @current_community.nil? 
      response.status = 404
      render :json => ["No community found with given id"] and return
    end
    
    unless @listing.communities.include?(@current_community)
      response.status = 400
      render :json => ["This listing is not visible in given community."] and return
    end
      
    @comment = Comment.new(:content => params[:content], :listing_id => params[:listing_id], :author_id => current_person.id)
    # Check that authorized to comment
    unless @comment.listing.visible_to?(@current_user, @current_community)
      response.status = :forbidden
      render :json => ["The user doesn't have a permission to see this listing"] and return
    end
    
    if @comment.save
      response.status = :created
      Delayed::Job.enqueue(CommentCreatedJob.new(@comment.id, @current_community.id, @current_community.full_domain ))
      respond_with @comment
    else
      response.status = 400
      render :json => [@comment.errors.full_messages] and return
    end
  end


end
