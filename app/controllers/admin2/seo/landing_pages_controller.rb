module Admin2::Seo
  class LandingPagesController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_landing_page
      @current_community.update!(landing_page_params)
      flash[:notice] = t('admin2.notifications.landing_pages_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_seo_landing_pages_path
    end

    private

    def landing_page_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id meta_title meta_description])
    end
  end
end
