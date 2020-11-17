module Admin2::Seo
  class ListingPagesController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_listing_page
      @current_community.update!(listing_page_params)
      render json: { message: t('admin2.notifications.listing_pages_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    def listing_page_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id listing_meta_title listing_meta_description])
    end
  end
end
