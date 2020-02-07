module Admin2::Listings
  class ListingApprovalController < Admin2::AdminBaseController

    def index; end

    def update_listing_approval
      @current_community.update!(listing_approval_params)
      flash[:notice] = t('admin2.notifications.listing_approval_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_listing_approval_index_path
    end

    private

    def listing_approval_params
      params.require(:community).permit(:pre_approved_listings)
    end
  end
end
