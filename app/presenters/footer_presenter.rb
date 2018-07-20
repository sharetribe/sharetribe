class FooterPresenter < MemoisticPresenter
  attr_reader :community, :plan, :locale

  def initialize(community, plan)
    @community = community
    @plan = plan
    @locale = I18n.locale
  end

  def display?
    FeatureFlagHelper.feature_enabled?(:footer)
  end

  def links?
    links.any?
  end

  def social?
    social.any?
  end

  def container_modifier
    links? && social? ? "" : "--center"
  end

  def theme
    community.footer_theme
  end

  def social_media_icon_color
    'FFFFFF'
  end

  def social_media_icon_color_hover
    'D9D9D9'
  end

  def copyright
    community.footer_copyright
  end

  def links
    community.footer_menu_links.map do |link|
      OpenStruct.new(
        title: link.title(locale),
        url: link.url(locale)
      )
    end
  end

  def social
    community.social_links.enabled
  end

  memoize_all_reader_methods
end
