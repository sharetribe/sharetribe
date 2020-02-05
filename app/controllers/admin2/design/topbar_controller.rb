module Admin2::Design
  class TopbarController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_topbar
      @current_community.update!(display_params)
      update_post_new_link!
      flash[:notice] = t('admin2.notifications.topbar_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_design_topbar_index_path
    end

    private

    def update_post_new_link!
      translations = params.to_unsafe_hash[:post_new_listing_button].map { |k, v| { locale: k, translation: v } }
      translations_group = [{ translation_key: 'homepage.index.post_new_listing',
                              translations: translations }]
      TranslationService::API::Api.translations.create(@current_community.id, translations_group)
    end

    def display_params
      params.require(:community).permit(:logo_link,
                                        menu_links_attributes:
                                          [:sort_priority, :id, :_destroy,
                                           translations_attributes: [:id, :url, :title, :locale]],
                                        configuration_attributes:
                                          [:limit_priority_links, :display_about_menu, :display_contact_menu, :display_invite_menu, :id])
    end
  end
end
