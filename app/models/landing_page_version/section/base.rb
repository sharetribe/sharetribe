module LandingPageVersion::Section
  class Base
    include ActiveModel::Model
    include ActiveModel::Serialization

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

    def add_or_replace_asset(new_asset, image_id)
      assets = landing_page_version.parsed_content['assets']
      item = assets.find{|x| x['id'] == image_id }
      unless item
        item = {'id' => image_id}
        assets << item
      end
      blob = new_asset.blob
      item['src'] = blob_path(blob)
      item['content_type'] = blob.content_type
      item['absolute_path'] = true
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

    def blob_path(blob)
      Rails.application.routes.url_helpers.landing_page_asset_path(signed_id: blob.signed_id, filename: blob.filename.to_s, sitename: landing_page_version.community.ident, only_path: true)
    end
  end
end
