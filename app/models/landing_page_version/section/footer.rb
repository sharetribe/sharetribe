module LandingPageVersion::Section
  class Footer < Base

    class SocialLink
      include ActiveModel::Model

      ATTRIBUTES = [:id, :provider, :url, :sort_priority, :enabled]

      attr_accessor *ATTRIBUTES

      def enabled?
        enabled
      end
    end

    class MenuLink
      include ActiveModel::Model

      ATTRIBUTES = [:id, :title, :url, :sort_priority, :_destroy]

      attr_accessor *ATTRIBUTES

      def new_record?
        id.nil?
      end
    end

    ATTRIBUTES = [
      :id,
      :kind,
      :theme,
      :social_media_icon_color,
      :social_media_icon_color_hover,
      :links,
      :social,
      :copyright,
    ].freeze

    DEFAULTS = {
      id: "footer",
      kind: "footer",
      theme: "logo",
      social_media_icon_color: {type: "marketplace_data", id: "primary_color"},
      social_media_icon_color_hover: {type: "marketplace_data", id: "primary_color_darken"},
      links: [
      ],
      social: [
        {service: "facebook", url: ""},
        {service: "twitter", url: ""},
        {service: "instagram", url: ""},
        {service: "youtube", url: ""},
        {service: "googleplus", url: ""},
        {service: "linkedin", url: ""},
        {service: "pinterest", url: ""}
      ],
      copyright: ""
    }.freeze

    PERMITTED_PARAMS = [
      :id,
      :kind,
      :theme,
      :previous_id,
      :links,
      :social,
      :copyright,
      :social_links_attributes => LandingPageVersion::Section::Footer::SocialLink::ATTRIBUTES,
      :footer_menu_links_attributes => LandingPageVersion::Section::Footer::MenuLink::ATTRIBUTES,
    ].freeze

    attr_accessor(*(ATTRIBUTES + HELPER_ATTRIBUTES))

    def initialize(attributes={})
      super(DEFAULTS.merge(attributes))
      @kind = LandingPageVersion::Section::FOOTER
    end

    def attributes
      Hash[ATTRIBUTES.map {|x| [x, nil]}]
    end

    def removable?
      false
    end

    def social_links
      self.social.map.with_index do |link, index|
        LandingPageVersion::Section::Footer::SocialLink.new(
          id: link['service'],
          provider: link['service'],
          url: link['url'],
          sort_priority: index,
          enabled: link['enabled'] == nil || link['enabled'] == true)
      end
    end

    def social_links_attributes=(params)
      self.social = priority_sort(params).map do |attrs|
        { service: attrs['id'], url: attrs['url'], enabled: attrs['enabled'] != '0' }
      end
    end

    def footer_menu_links
      self.links.map.with_index do |link, index|
        LandingPageVersion::Section::Footer::MenuLink.new(
          id: index,
          title: link['label'],
          url: link['href']['value'],
          sort_priority: index)
      end
    end

    def footer_menu_links_attributes=(params)
      self.links = priority_sort(params).reject{|r| r['_destroy'] == '1'}.map do |attrs|
        { label: attrs['title'], href: {value: attrs['url']} }
      end
    end

    def new_footer_menu_link
      LandingPageVersion::Section::Footer::MenuLink.new
    end

    def priority_sort(params)
      params.values.sort_by{|p| p['sort_priority'].to_i}
    end

    class << self
      def new_from_content(content_section)
        new(content_section)
      end

      def permitted_params
        PERMITTED_PARAMS
      end
    end
  end
end
