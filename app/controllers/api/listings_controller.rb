class Api::ListingsController < Api::ApiController

  #before_filter :authenticate_person!
  
  def index
    #puts params.inspect
    query = params.slice("status", "category")
    query["listing_type"] = params["type"] if params["type"]
    #query[""]
    #puts query.inspect
    if params["community_id"]
      @listings = Community.find(params["community_id"]).listings.where(query)
    else
      @listings = Listing.where(query)
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