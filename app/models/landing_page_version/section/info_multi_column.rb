module LandingPageVersion::Section
  class InfoMultiColumn < Info

    attr_accessor :multi_columns

    DEFAULTS = {
      variation: "multi_column",
      title: nil,
      background_image: nil,
      background_image_variation: nil,
      button_color: {
        type: "marketplace_data",
        id: "primary_color"
      },
      button_color_hover: {
        type: "marketplace_data",
        id: "primary_color_darken"
      },
      icon_color: {
        type: "marketplace_data",
        id: "primary_color"
      },
      columns: [],
      button_title: nil,
      button_path: nil
    }

    COLUMN_DEFAULTS = {
      icon: 'piggy-bank',
      title: nil,
      paragraph: nil,
      button_title: nil,
      button_path: nil
    }.with_indifferent_access

    EXTRA_PERMITTED_PARAMS = [
      :cta_enabled,
      :button_title,
      :button_path_string,
      :background_style,
      :background_color_string,
      :background_image_variation,
      :multi_columns,
      :columns => [ :icon, :title, :paragraph, :button_title, :button_path => [:value] ]
    ]

    def initialize(attributes={})
      attributes = attributes.is_a?(Hash) ? attributes : attributes.to_unsafe_hash
      add_columns(attributes)
      super(attributes)
      DEFAULTS.each do |key, value|
        unless self.send(key)
          self.send("#{key}=", value)
        end
      end
    end

    def add_columns(attributes)
      columns = attributes['columns'].dup || []
      unless columns.is_a?(Array)
        columns = []
        attributes['columns'].each do |k, v|
          columns[k.to_i] = v
        end
      end

      if attributes['multi_columns'].present?
        n = attributes['multi_columns'].to_i
        n = 2 if n != 2 && n != 3
      else
        n = 2
      end

      columns.size.upto(n-1){ columns << COLUMN_DEFAULTS.dup }
      columns = columns[0,3] if columns.size > 3
      attributes['columns'] = columns
    end

    def attributes=(attributes)
      add_columns(attributes)
      super
    end

    def i18n_key
      'info_multi_column_' + columns.size.to_s
    end

    class << self
      def permitted_params
        LandingPageVersion::Section::Info::PERMITTED_PARAMS + EXTRA_PERMITTED_PARAMS
      end
    end
  end
end
