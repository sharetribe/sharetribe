class IntApi::Listing::BookingsController < ApplicationController
  respond_to :json

  def index
    respond_with listing.booked_dates(params[:start_on], params[:end_on]).sort, location: nil
  end

  private

  def listing
    @listing ||= Listing.find(params[:listing_id])
  end
end
