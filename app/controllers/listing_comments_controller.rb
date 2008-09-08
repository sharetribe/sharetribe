class ListingCommentsController < ApplicationController

  def create
    @listing = Listing.find(params[:listing_id])
    @listing_comment = ListingComment.new(params[:listing_comment])
    @listing_comment.author_id = @listing.id
    if (@listing_comment.save)
      flash[:notice] = "comment_added"
    else
      flash[:error] = "comment_not_added"
    end  
    respond_to do |format|
      format.html { redirect_to @listing }
      format.js  
    end
  end

end
