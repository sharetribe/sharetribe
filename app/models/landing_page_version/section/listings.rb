module LandingPageVersion::Section
  class Listings < Base
    ATTRIBUTES = [
      :id,
      :kind,
      :title,
      :paragraph,
      :button_color,
      :button_color_hover,
      :button_title,
      :button_path,
      :price_color,
      :no_listing_image_background_color,
      :no_listing_image_text,
      :author_name_color_hover,
      :listings
    ].freeze

    PERMITTED_PARAMS = [
      :kind,
      :id,
      :previous_id,
      :title,
      :paragraph,
      :cta_enabled,
      :button_title,
      :button_path_string,
      :listing_1_id,
      :listing_2_id,
      :listing_3_id
    ].freeze

    DEFAULTS = {
      kind: "listings",
      title: nil,
      paragraph: nil,
      button_color: {type: "marketplace_data", id: "primary_color"},
      button_color_hover: {type: "marketplace_data", id: "primary_color_darken"},
      button_title: nil,
      button_path: {type: "path", id: "search"},
      price_color: {type: "marketplace_data", id: "primary_color"},
      no_listing_image_background_color: {type: "marketplace_data", id: "primary_color"},
      no_listing_image_text: {type: "translation", id: "no_listing_image"},
      author_name_color_hover: {type: "marketplace_data", id: "primary_color"},
      'listings' => [
        {
          'listing' => { 'type' => 'listing', 'id' => nil }
        },
        {
          'listing' => { 'type' => 'listing', 'id' => nil }
        },
        {
          'listing' => { 'type' => 'listing', 'id' => nil }
        }
      ]
    }.freeze

    attr_accessor(*(ATTRIBUTES + HELPER_ATTRIBUTES))

    validates_each :listing_1_id, :listing_2_id, :listing_3_id do |record, attr, value|
      unless record.landing_page_version.community.listings.where(id: value).any?
        record.errors.add attr, :listing_with_this_id_does_not_exist
      end
    end

    before_save :check_extra_attributes

    def initialize(attributes={})
      self.listings = DEFAULTS['listings']
      super(attributes)
      DEFAULTS.each do |key, value|
        unless self.send(key)
          self.send("#{key}=", value)
        end
      end
    end

    def attributes
      Hash[ATTRIBUTES.map {|x| [x.to_s, nil]}]
    end

    def cta_enabled
      return @cta_enabled if defined?(@cta_enabled)

      @cta_enabled = button_title.present?
    end

    def cta_enabled=(value)
      @cta_enabled = value != '0'
    end

    def button_path_string=(value)
      self.button_path = {'value' => value}
    end

    def button_path_string
      button_path&.[]('value')
    end

    def check_extra_attributes
      unless cta_enabled
        self.button_title = nil
        self.button_path = nil
      end
    end

    def i18n_key
      'listings'
    end

    def listing_1_id
      listing_id(0)
    end

    def listing_2_id
      listing_id(1)
    end

    def listing_3_id
      listing_id(2)
    end

    def listing_1_id=(value)
      set_listing_id(0, value)
    end

    def listing_2_id=(value)
      set_listing_id(1, value)
    end

    def listing_3_id=(value)
      set_listing_id(2, value)
    end

    def listing_id(index)
      listings[index]['listing']['id']
    end

    def set_listing_id(index, value)
      listings[index]['listing']['id'] = value
    end

    def removable?
      true
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
