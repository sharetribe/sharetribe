class InterestingListingsController < ApplicationController

  def index
    @title = :interesting_listings
    save_navi_state(['own', 'interesting_listings'])
    @listing_amount = @current_user.int_listings.size
    @pagination_type = "interesting_listings"
    @listings = @current_user.int_listings.paginate :page => params[:page], 
                                 :per_page => per_page.to_i, 
                                 :order => 'id DESC'
    render :template => "listings/index"
  end

  def create
    unless InterestingListing.find_by_person_id_and_listing_id(@current_user.id, params[:listing_id]) 
      @current_user.interesting_listings.create(:listing_id => params[:listing_id])
    end
    redirect_to listing_path(Listing.find(params[:listing_id]))   
  end
  
  def destroy
    InterestingListing.find_by_person_id_and_listing_id(@current_user.id, params[:id]).destroy
    redirect_to listing_path(Listing.find(params[:id]))
  end

end
