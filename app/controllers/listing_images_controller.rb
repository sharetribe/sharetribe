class ListingImagesController < ApplicationController
  
  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_filter :verify_authenticity_token, :only => [:destroy]

  before_filter :fetch_image
  before_filter :authorized, :only => [:destroy]

  skip_filter :dashboard_only
  
  def destroy
    @listing_image_id = @listing_image.id.to_s
    @listing_image.destroy
    respond_to do |format|
      format.html {redirect_to @listing}
      format.js {render :layout => false}
    end
  end

  def fetch_image
    @listing = Listing.find(params[:listing_id])
    @listing_image = ListingImage.find_by_id_and_listing_id(params[:id], params[:listing_id])
  end

  def authorized
    not_authorized = @listing.author != @current_user

    if not_authorized
      respond_to do |format|
        format.html {redirect_to @listing}
        format.js {render :nothing => true, :status => :unauthorized}
      end
    end
  end
  
end
