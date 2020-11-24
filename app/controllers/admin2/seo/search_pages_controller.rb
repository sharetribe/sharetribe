module Admin2::Seo
  class SearchPagesController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_search_pages
      @current_community.update!(search_pages_params)
      flash[:notice] = t('admin2.notifications.search_pages_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_seo_search_pages_path
    end

    private

    def search_pages_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id search_meta_title search_meta_description])
    end
  end
end
