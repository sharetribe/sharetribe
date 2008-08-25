class ListingCommentsController < ApplicationController

  def create
    @listing = Listing.find(params[:listing_id])
    @listing.comments.create(params[:listing_comment])
    flash[:notice] = "comment_added"
    respond_to do |format|
      format.html { redirect_to @listing }
      format.js  
    end
  end

end
