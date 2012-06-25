class Api::ListingsController < Api::ApiController
  respond_to :json


  def index
    respond_with Listing.all
  end

  def show
    respond_with Listing.find(params[:id])
  end

  def create
    respond_with Listing.create(params[:listing])
  end

end