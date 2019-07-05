module CustomLandingPage
  class SectionService
    attr_reader :community, :params

    def initialize(community:, params:)
      @params = params
      @community = community
      @editor_service = CustomLandingPage::EditorService.new(community: community, params: params)
      @asset_resolver = CustomLandingPage::LinkResolver::AssetResolver.new(APP_CONFIG[:clp_asset_url], community.ident)
    end

    def landing_page_version
      @editor_service.landing_page_version
    end

    def new_section
      section_from_params
      section.previous_id = nil
      section
    end

    def section
      @section ||= landing_page_version.sections.find{|x| x.id == params[:id]}
    end

    def create
      create_or_update
    end

    def update
      create_or_update(update: true)
    end

    def destroy
      section.destroy! if section.removable?
    end

    def asset_url(section_id, image_key)
      section = landing_page_version.sections.detect{|s| s.id == section_id }
      return nil unless section

      result = @asset_resolver.call('assets', section.background_image['id'], landing_page_version.parsed_content)
      result['file'] = result['src'].split('/').last
      result
    rescue StandardError => e
      nil
    end

    private

    def create_or_update(update: false)
      section_from_params
      section.update = update
      if params['bg_image'].present?
        asset = community.landing_page_assets.attach(create_blob(params[:bg_image])).first
        if asset.valid?
          section.asset_added(asset)
        end
      end
      section.save
    end

    def landing_page_versions_scope
      LandingPageVersion.where(community: community)
    end

    def section_params
      params.require(:section).permit(section_factory_class.permitted_params)
    end

    def section_factory_class
      case params[:section][:kind]
      when LandingPageVersion::Section::INFO
        LandingPageVersion::Section::Info
      when LandingPageVersion::Section::HERO
        LandingPageVersion::Section::Hero
      when LandingPageVersion::Section::FOOTER
        LandingPageVersion::Section::Footer
      end
    end

    def section_from_params
      @section = section_factory_class.new_from_content(section_params)
      section.landing_page_version = landing_page_version
      section.id = params[:id] if params[:id].present?
      section
    end

    # NOTE: we want to store these assets like s3://%{clp_s3_bucket}/sites/%{sitename}/heroBG.jpg
    # but since ActiveStorage does not support key prefixes, have to explicitly defined required key
    # and perform upload here
    def create_blob(http_uploaded_file)
      io = http_uploaded_file.open

      blob = ActiveStorage::Blob.new
      blob.filename = http_uploaded_file.original_filename
      blob.content_type = http_uploaded_file.content_type
      blob.key = File.join('sites', community.ident, ActiveStorage::Blob.generate_unique_secure_token)
      blob.upload(io)

      blob.save
      blob
    end
  end
end
