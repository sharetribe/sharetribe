class Admin::Communities::FooterService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def footer_menu_links # rubocop:disable Rails/Delegate
    community.footer_menu_links
  end

  def new_footer_menu_link
    community.footer_menu_links.build
  end

  def update
    community.update_attributes(footer_params)
  end

  def footer_theme_dark?
    community.footer_theme == Community::FOOTER_DARK
  end

  private

  def footer_params
    params.require(:community).permit(
      :footer_theme, :footer_copyright,
      footer_menu_links_attributes: [
        :id, :entity_type, :sort_priority, :_destroy,
        translation_attributes: Hash[community.locales.collect { |item| [item.to_sym, [:title, :url]] } ]
      ]
    )
  end

  def configuration_params
    params.require(:configuration).permit(:footer_style)
  end
end
