module Admin2::Seo
  class CategoryPagesController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_category_page
      @current_community.update!(category_page_params)
      flash[:notice] = t('admin2.notifications.category_pages_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_seo_category_pages_path
    end

    private

    def category_page_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id category_meta_title category_meta_description])
    end
  end
end
