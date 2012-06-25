class Api::ListingsController < Api::ApiController
  respond_to :json


  def index
    if params[:community_id]
      @listings = Community.find(params[:community_id]).listings
    else
      @listings = Listing.all
    end
    respond_with @listings
  end

  def show
    @listing = Listing.find(params[:id])
    respond_with @listing
  end

  def create
    respond_with Listing.create(params[:listing])
  end

end