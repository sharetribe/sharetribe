class ListingImagesController < ApplicationController
  
  def destroy
    @listing_image = ListingImage.find(params[:id]).destroy
    @listing_image_id = @listing_image.id.to_s
    @listing_image.destroy
    @listing = Listing.find(params[:listing_id])
    respond_to do |format|
      format.html {redirect_to @listing}
      format.js {render :layout => false}
    end
  end
  
end
