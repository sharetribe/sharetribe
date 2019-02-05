class FooterPresenter < MemoisticPresenter
  attr_reader :community, :plan, :locale

  def initialize(community, plan)
    @community = community
    @plan = plan
    @locale = I18n.locale
  end

  def display?
    plan && !!plan[:features][:footer] &&
      community.footer_enabled
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
    community.custom_color1 || (theme_dark? ? 'FFFFFF' : '4a90e2')
  end

  def social_media_icon_color_hover
    if community.custom_color1.present?
      (0..2).map{ |x| community.custom_color1.slice(x*2, 2).to_i(16) }.join(',')
    else
      (theme_dark? ? '217,217,217' : '74,144,226')
    end
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

  def theme_dark?
    community.footer_theme == Community::FOOTER_DARK
  end

  def custom_color
    community.custom_color1 || '4a90e2'
  end

  def theme_logo?
    community.footer_theme == Community::FOOTER_LOGO
  end

  def show_logo?
    theme_logo? && community.wide_logo.file?
  end

  def logo
    community.wide_logo.url(:header_highres)
  end

  memoize_all_reader_methods
end
