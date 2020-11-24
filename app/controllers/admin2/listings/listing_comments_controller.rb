module Admin2::Listings
  class ListingCommentsController < Admin2::AdminBaseController

    def index; end

    def update_listing_comments
      @current_community.update!(listing_comments_params)
      flash[:notice] = t('admin2.notifications.listing_comments_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_listing_comments_path
    end

    private

    def listing_comments_params
      params.require(:community).permit(:listing_comments_in_use)
    end
  end
end
