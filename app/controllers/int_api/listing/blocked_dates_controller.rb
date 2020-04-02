class IntApi::Listing::BlockedDatesController < ApplicationController
  respond_to :json

  def index
    respond_with listing.blocked_dates.in_period(params[:start_on], params[:end_on]), location: nil
  end

  private

  def listing
    @listing ||= Listing.find(params[:listing_id])
  end
end
