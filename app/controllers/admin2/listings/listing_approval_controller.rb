module Admin2::Listings
  class ListingApprovalController < Admin2::AdminBaseController

    def index; end

    def update_listing_approval
      @current_community.update!(listing_approval_params)
      render json: { message: t('admin2.notifications.listing_approval_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    def listing_approval_params
      params.require(:community).permit(:pre_approved_listings)
    end
  end
end
