module Admin2::Seo
  class CategoryPagesController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_category_page
      @current_community.update!(category_page_params)
      render json: { message: t('admin2.notifications.category_pages_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def category_page_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id category_meta_title category_meta_description])
    end
  end
end
