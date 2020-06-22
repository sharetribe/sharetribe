class IntApi::Listing::BookingsController < ApplicationController
  respond_to :json

  def index
    respond_with listing.booked_dates(params[:start_on].to_date, params[:end_on].to_date).sort, location: nil
  end

  private

  def listing
    @listing ||= Listing.find(params[:listing_id])
  end
end
