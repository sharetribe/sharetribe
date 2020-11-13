module Admin2::Seo
  class LandingPagesController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_landing_page
      @current_community.update!(landing_page_params)
      render json: { message: t('admin2.notifications.landing_pages_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    def landing_page_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id meta_title meta_description])
    end
  end
end
