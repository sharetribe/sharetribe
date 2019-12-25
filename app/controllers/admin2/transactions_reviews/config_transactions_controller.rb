module Admin2::TransactionsReviews
  class ConfigTransactionsController < Admin2::AdminBaseController

    def index; end

    def update_config
      @current_community.update!(config_params)
      flash[:notice] = t('admin2.notifications.listing_approval_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_listings_listing_approval_index_path
    end

    private

    def config_params
      params.require(:community).permit(:pre_approved_listings)
    end
  end
end
