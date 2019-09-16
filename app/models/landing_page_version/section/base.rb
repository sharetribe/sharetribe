module LandingPageVersion::Section
  class Base
    include ActiveModel::Model
    include ActiveModel::Serialization
    include ActiveModel::Validations::Callbacks

    extend ActiveModel::Callbacks

    define_model_callbacks :save

    HELPER_ATTRIBUTES = [
      :update,
      :success,
      :landing_page_version,
      :previous_id,
    ].freeze

    validates :landing_page_version, presence: true
    validates :id, presence: true
    validates :kind, presence: true
    validate :not_overwrite_another_section

    before_validation :normalize_id_for_css

    def save
      ActiveRecord::Base.transaction do
        # Valid will setup the Form object errors
        if valid?
          run_callbacks :save do
            persist!
          end
          @success = true
        else
          @success = false
        end
      end
    end

    def model_name
      ActiveModel::Name.new(self, nil, 'section')
    end

    def destroy!
      new_content = landing_page_version.parsed_content.dup
      new_content['sections'].delete_if{|x| x['id'] == id}
      composition = new_content['composition']
      composition.delete_if{|x| x['section']['id'] == id}
      landing_page_version.update_content(new_content)
    end

    def persisted?
      previous_id.present? && find_existing_section_by_id(id)
    end

    def asset_added(asset); end

    def add_or_replace_asset(new_asset, image_id, resize_options = {})
      assets = landing_page_version.parsed_content['assets']
      item = assets.find{|x| x['id'] == image_id }
      unless item
        item = {'id' => image_id}
        assets << item
      end
      disk_service = new_asset.service.class.to_s == 'ActiveStorage::Service::DiskService'
      result_asset = if resize_options.any?
        variant = new_asset.variant(resize_options)
        variant.processed
      else
        new_asset
      end
      service_url = if disk_service
        Rails.application.routes.url_helpers.polymorphic_url(result_asset, only_path: true)
      else
        result_asset.service_url
      end
      uri = URI.parse(service_url)
      if disk_service
        item['src'] = service_url
        item['absolute_path'] = true
      else
        item['src'] = uri.path.sub(/\/[^\/]*\/[^\/]*\//, '') # remove "/sites/sitename/"
        item['absolute_path'] = false
      end
      item['content_type'] = new_asset.blob.content_type
      item['asset_id'] = new_asset.id
      item
    end

    def i18n_key
      'section'
    end

    def background_color_string
      if background_color.is_a?(Array)
        background_color.map{|c| format("%02x", c) }.join("")
      else
        ""
      end
    end

    def background_color_string=(value)
      rgb = value.to_s.scan(/[0-9a-fA-F]{2}/).map{|c| c.to_i(16) }
      self.background_color = rgb.size == 3 ? rgb : nil
    end

    def check_extra_attributes
      unless cta_enabled
        self.button_title = nil
        self.button_path = nil
      end

      self.background_color = nil unless background_style == LandingPageVersion::Section::BACKGROUND_STYLE_COLOR
      self.background_image = nil unless background_style == LandingPageVersion::Section::BACKGROUND_STYLE_IMAGE
    end

    def background_style
      @background_style ||=
        if background_image.present?
          LandingPageVersion::Section::BACKGROUND_STYLE_IMAGE
        elsif background_color.present?
          LandingPageVersion::Section::BACKGROUND_STYLE_COLOR
        else
          LandingPageVersion::Section::BACKGROUND_STYLE_NONE
        end
    end

    def cta_enabled
      return @cta_enabled if defined?(@cta_enabled)

      @cta_enabled = button_title.present?
    end

    def cta_enabled=(value)
      @cta_enabled = value != '0'
    end

    def button_path_string=(value)
      self.button_path = {value: value}
    end

    def button_path_string
      button_path&.[]('value')
    end

    private

    def persist!
      new_content = landing_page_version.parsed_content.dup
      new_content['sections'].delete_if{|x| x['id'] == id}
      new_content['sections'] << self.serializable_hash
      composition = new_content['composition']
      unless composition.find{|x| x['section']['id'] == id}
        composition << { 'section' => {'type' => 'sections', 'id' => id }}
      end
      landing_page_version.update_content(new_content)
    end

    def not_overwrite_another_section
      if previous_id != id && find_existing_section_by_id(id)
        errors.add(:id, :section_with_this_id_already_exists)
      end
    end

    def find_existing_section_by_id(identifier)
      landing_page_version.parsed_content['sections'].find{|x| x['id'] == identifier}
    end

    # normalize section id to be usable as part of html element "id" and "class" attributes
    def normalize_id_for_css
      self.id = self.id.to_s.strip.gsub(/\s+/,'-').gsub(/[^-A-Z0-9_]/i,'').gsub(/^[^A-Z]+/i, '').gsub(/-+/,'-').sub(/-+$/,'')
    end
  end
end

