class Admin2::FooterService
  attr_reader :community, :params, :plan

  def initialize(community:, params:, plan:)
    @params = params
    @community = community
    @plan = plan
  end

  def plan_footer_disabled?
    return true unless plan

    !plan.dig(:features, :footer).present?
  end

  def footer_menu_links # rubocop:disable Rails/Delegate
    community.footer_menu_links
  end

  def new_footer_menu_link
    community.footer_menu_links.build
  end

  def update
    enable_social_link
    community.update(footer_params) && community.footer_menu_links.map(&:save).all?
  end

  def enable_social_link
    params[:community][:social_links_attributes].each do |_index, link|
      link[:enabled] = link[:url].present?
    end
  end

  def social_links
    return @social_links if @social_links.present?

    SocialLink.social_provider_list.each do |provider|
      next if community.social_links.by_provider(provider).any?

      community.social_links.build(provider: provider)
    end
    @social_links = community.social_links
  end

  def footer_themes
    Community::FOOTER_THEMES.keys.map do |theme|
      OpenStruct.new(key: theme, value: I18n.t("admin2.footer.style.#{theme}"))
    end
  end

  private

  def footer_params
    params.require(:community).permit(
      :footer_theme, :footer_copyright, :footer_enabled,
      footer_menu_links_attributes: [
        :id, :entity_type, :sort_priority, :_destroy,
        translations_attributes: [:id, :url, :title, :locale]
      ],
      social_links_attributes: [
        :id, :provider, :url, :sort_priority, :enabled
      ])
  end
end
