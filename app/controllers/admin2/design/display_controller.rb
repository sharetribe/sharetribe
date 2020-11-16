module Admin2::Design
  class DisplayController < Admin2::AdminBaseController

    def index; end

    def update_display
      @current_community.update!(display_params)
      render json: { message: t('admin2.notifications.display_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def display_params
      params.require(:community).permit(:show_category_in_listing_list,
                                        :show_listing_publishing_date,
                                        :name_display_type,
                                        :default_browse_view)
    end
  end
end
