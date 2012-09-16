class ListingImagesController < ApplicationController
  
  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:destroy]
  
  
  skip_filter :dashboard_only
  
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
