class IntApi::Listing::BookingsController < ApplicationController
  respond_to :json

  before_action :ensure_current_user_is_listing_author

  def index
    respond_with listing.booked_dates(params[:start_on].to_date, params[:end_on].to_date).sort, location: nil
  end

  private

  def listing
    @listing ||= @current_community.listings.find(params[:listing_id])
  end

  def ensure_current_user_is_listing_author
    return true if !listing.deleted? && (current_user?(listing.author) || @current_user.has_admin_rights?(@current_community))

    head(:forbidden)
  end
end
