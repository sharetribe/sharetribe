module Admin2::Listings
  class ListingCommentsController < Admin2::AdminBaseController

    def index; end

    def update_listing_comments
      @current_community.update!(listing_comments_params)
      render json: { message: t('admin2.notifications.listing_comments_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def listing_comments_params
      params.require(:community).permit(:listing_comments_in_use)
    end
  end
end
