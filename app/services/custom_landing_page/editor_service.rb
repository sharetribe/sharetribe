module CustomLandingPage
  class EditorService
    attr_reader :community, :params, :landing_page_version

    def initialize(community:, params:)
      @params = params
      @community = community
    end

    def update_landing_page_version
      landing_page_version.update(landing_page_version_params)
    end

    def release_landing_page_version
      if latest_version_has_changes?
        CustomLandingPage::LandingPageStoreDB.release_version!(community.id, landing_page_version.version)
        Delayed::Job.enqueue(CleanupLandingPageAssetsJob.new(community.id))

        true
      else
        false
      end
    end

    def errors?
      landing_page_version.errors.any?
    end

    def ensure_latest_version_exists!
      lp = LandingPage.where(community: community).first_or_create

      last_version = LandingPageVersion.where(community: community).order('version DESC').first

      last_version ||= LandingPageVersion.create(community: community, version: 1, content: blank_version.to_json)

      if lp.enabled && last_version.version == lp.released_version
        last_version = last_version.dup
        last_version.version += 1
        last_version.save
      end

      @landing_page_version = last_version
    end

    private

    def landing_page_version_params
      params.require(:landing_page_version).permit(
        :content,
        section_positions_attributes: [
          :id,
          :position
        ]
      )
    end

    def blank_version
      {
        settings: {
          marketplace_id: community.id,
          locale: community.default_locale,
          sitename: community.ident
        },
        page: {
          twitter_handle: {type: "marketplace_data", id: "twitter_handle"},
          twitter_image: {type: "assets", id: "default_hero_background"},
          facebook_image: {type: "assets", id: "default_hero_background"},
          title: {type: "marketplace_data", id: "page_title"},
          description: {type: "marketplace_data", id: "description"},
          publisher: {type: "marketplace_data", id: "name"},
          copyright: {type: "marketplace_data", id: "name"},
          facebook_site_name: {type: "marketplace_data", id: "name"},
          google_site_verification: {value: "CHANGEME"}
        },
        sections: [
          LandingPageVersion::Section::Hero::DEFAULTS,
          LandingPageVersion::Section::Footer::DEFAULTS,
        ],
        composition: [
          { section: {type: "sections", id: "hero"}},
          { section: {type: "sections", id: "footer"}},
        ],
        assets: [
          { id: "default_hero_background", src: "default_hero_background.jpg", content_type: "image/jpeg" }
        ]
      }
    end

    def released_landing_page_version
      return @released_landing_page_version if defined?(@released_landing_page_version)

      released_version = LandingPage.released_version(community)
      @released_landing_page_version = LandingPageVersion.where(community: community, version: released_version).first
    end

    def latest_version_has_changes?
      if released_landing_page_version
        return released_landing_page_version.content != landing_page_version.content
      end

      true
    end
  end
end
