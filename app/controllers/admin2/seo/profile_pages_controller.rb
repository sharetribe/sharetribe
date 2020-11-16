module Admin2::Seo
  class ProfilePagesController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_profile_page
      @current_community.update!(profile_page_params)
      render json: { message: t('admin2.notifications.profile_pages_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def profile_page_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id profile_meta_title profile_meta_description])
    end
  end
end
