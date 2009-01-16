class ListingCommentsController < ApplicationController

  before_filter :logged_in

  def create
    @listing = Listing.find(params[:listing_id])
    params[:listing_comment][:listing_id] = @listing.id.to_s
    @comment = ListingComment.new(params[:listing_comment])
    if @comment.save
      flash[:notice] = "comment_added"  
      respond_to do |format|
        format.html { redirect_to @listing }
        format.js  
      end
    else 
      flash[:error] = :empty_comment_not_accepted 
      redirect_to @listing
    end    
  end

end
