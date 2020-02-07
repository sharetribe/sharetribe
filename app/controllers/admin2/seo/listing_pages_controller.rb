module Admin2::Seo
  class ListingPagesController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_listing_page
      @current_community.update!(listing_page_params)
      flash[:notice] = t('admin2.notifications.listing_pages_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_seo_listing_pages_path
    end

    private

    def listing_page_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id listing_meta_title listing_meta_description])
    end
  end
end
