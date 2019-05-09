class Admin::Communities::FooterService
  attr_reader :community, :params, :plan

  def initialize(community:, params:, plan:)
    @params = params
    @community = community
    @plan = plan
  end

  def plan_footer_disabled?
    if plan
      !plan[:features][:footer] ? true : nil
    else
      true
    end
  end

  def footer_menu_links # rubocop:disable Rails/Delegate
    community.footer_menu_links
  end

  def new_footer_menu_link
    community.footer_menu_links.build
  end

  def update
    community.update(footer_params) &&
      community.footer_menu_links.map(&:save).all?
  end

  def social_links
    return @social_links if defined?(@social_links)

    SocialLink.social_provider_list.each do |provider|
      next if community.social_links.by_provider(provider).any?

      community.social_links.build(provider: provider)
    end
    @social_links = community.social_links
  end

  def footer_themes
    Community::FOOTER_THEMES.keys.map do |theme|
      OpenStruct.new(key: theme, value: I18n.t("admin.communities.footer.style.#{theme}"))
    end
  end

  private

  def footer_params
    params.require(:community).permit(
      :footer_theme, :footer_copyright, :footer_enabled,
      footer_menu_links_attributes: [
        :id, :entity_type, :sort_priority, :_destroy,
        translation_attributes: Hash[community.locales.collect { |item| [item.to_sym, [:title, :url]] }]
      ],
      social_links_attributes: [
        :id, :provider, :url, :sort_priority, :enabled
      ]
    )
  end
end
