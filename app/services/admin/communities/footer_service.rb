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
    community.update_attributes(footer_params) &&
      community.footer_menu_links.map(&:save).all?
  end

  def footer_theme_dark?
    community.footer_theme == Community::FOOTER_DARK
  end

  def social_links
    return @social_links if defined?(@social_links)
    SocialLink.social_provider_list.each do |provider|
      next if community.social_links.by_provider(provider).any?
      community.social_links.build(provider: provider)
    end
    @social_links = community.social_links
  end

  private

  def footer_params
    params.require(:community).permit(
      :footer_theme, :footer_copyright, :footer_enabled,
      footer_menu_links_attributes: [
        :id, :entity_type, :sort_priority, :_destroy,
        translation_attributes: Hash[community.locales.collect { |item| [item.to_sym, [:title, :url]] } ]
      ],
      social_links_attributes: [
        :id, :provider, :url, :sort_priority, :enabled
      ]
    )
  end
end
