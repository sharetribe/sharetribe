module Admin2::Design
  class TopbarController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_topbar
      @current_community.update!(display_params)
      flash[:notice] = t('admin2.notifications.display_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_design_topbar_index_path
    end

    private

    def display_params
      params.require(:community).permit(menu_links_attributes: [:sort_priority, :id, :_destroy, translations_attributes: [:id, :url, :title, :locale]])
    end
  end
end
