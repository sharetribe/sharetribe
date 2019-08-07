module CustomLandingPage
  class SectionService
    attr_reader :community, :params

    def initialize(community:, params:)
      @params = params
      @community = community
    end

    def landing_page_version
      @landing_page_version ||= landing_page_versions_scope.find(params[:landing_page_version_id])
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

    private

    def create_or_update(update: false)
      if update
        section.attributes = section_params
      else
        section_from_params
      end
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
        case params[:section][:variation]
        when 'single_column'
          LandingPageVersion::Section::InfoSingleColumn
        when 'multi_column'
          LandingPageVersion::Section::InfoMultiColumn
        else
          LandingPageVersion::Section::Info
        end
      when LandingPageVersion::Section::HERO
        LandingPageVersion::Section::Hero
      when LandingPageVersion::Section::FOOTER
        LandingPageVersion::Section::Footer
      when LandingPageVersion::Section::LISTINGS
        LandingPageVersion::Section::Listings
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
