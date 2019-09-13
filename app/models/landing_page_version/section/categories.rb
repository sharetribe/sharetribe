module LandingPageVersion::Section
  class Categories < Base
    class Category
      include ActiveModel::Model

      ATTRIBUTES = [
        :id,
        :asset_id,
        :sort_priority,
        :_destroy,
        :image,
        :category_id
      ]

      attr_accessor(*ATTRIBUTES)

      def new_record?
        id.nil?
      end

      def self.from_serialized_hash(category, index)
        self.new(
          id: index,
          category_id: category['category']['id'],
          asset_id: category['background_image']['id'],
          sort_priority: index)
      end

      def serializable_hash(options = nil)
        {
          category: { type: "category", id: category_id.to_i},
          background_image: { type: "assets", id: asset_id}
        }
      end
    end

    ATTRIBUTES = [
      :id,
      :kind,
      :title,
      :paragraph,
      :button_color,
      :button_color_hover,
      :button_title,
      :button_path,
      :category_color_hover,
      :categories,
      :background_image_variation,
      :background_image,
      :background_color
    ].freeze

    DEFAULTS = {
      title: nil,
      background_image: nil,
      background_image_variation: nil,
      paragraph: nil,
      button_color: {type: "marketplace_data", id: "primary_color"},
      button_color_hover: {type: "marketplace_data", id: "primary_color_darken"},
      button_title: nil,
      button_path: nil,
      category_color_hover: {type: "marketplace_data", id: "primary_color"},
      categories: []
    }

    PERMITTED_PARAMS = [
      :id,
      :kind,
      :previous_id,
      :title,
      :paragraph,
      :button_title,
      :button_path_string,
      :cta_enabled,
      :button_title,
      :button_path_string,
      :background_style,
      :background_color_string,
      :background_image_variation,
      :categories_attributes => LandingPageVersion::Section::Categories::Category::ATTRIBUTES
    ]

    attr_accessor(*(ATTRIBUTES + HELPER_ATTRIBUTES))

    attr_writer :background_style

    before_save :check_extra_attributes

    def initialize(attributes={})
      super(attributes)
      @kind = LandingPageVersion::Section::CATEGORIES
      DEFAULTS.each do |key, value|
        unless self.send(key)
          self.send("#{key}=", value)
        end
      end
      categories << LandingPageVersion::Section::Categories::Category.new while categories.size < 3
    end

    def attributes
      Hash[ATTRIBUTES.map {|x| [x.to_s, nil]}]
    end

    def i18n_key
      'categories'
    end

    # serialize links and social as associations, not regular attributes
    def serializable_hash(options = nil)
      super({except: [:categories], include: [:categories]})
    end

    # called on initialization from model
    def categories=(list)
      @categories = list.map.with_index do |category, index|
        if category.is_a?(Hash)
          LandingPageVersion::Section::Categories::Category.from_serialized_hash(category, index)
        else
          category
        end
      end
    end

    # called from controller
    def categories_attributes=(params)
      @categories = priority_sort(params).reject{|r| r['_destroy'] == '1'}.map do |attrs|
        category = LandingPageVersion::Section::Categories::Category.new(attrs)
        new_asset = attrs['image']
        if new_asset.is_a?(ActiveStorage::Attachment)
          category.asset_id = category.asset_id.presence || "category_#{id}_#{new_asset.id}"
          add_or_replace_asset(new_asset, category.asset_id, CATEGORY_IMAGE_RESIZE_OPTIONS)
        end
        category
      end
    end

    def new_category
      LandingPageVersion::Section::Categories::Category.new
    end

    def priority_sort(params)
      params.values.sort_by{|p| p['sort_priority'].to_i}
    end

    def asset_added(new_asset)
      self.background_image = {'type' => 'assets', 'id' => self.id+"_background_image"}
      add_or_replace_asset(new_asset, background_image['id'], BACKGROUND_RESIZE_OPTIONS)
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
