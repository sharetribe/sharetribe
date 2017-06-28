module CustomLandingPage
  module LandingPageStoreDB

    class LandingPage < ApplicationRecord; end
    class LandingPageVersion < ApplicationRecord; end

    module_function

    #
    # Common methods with the static CLP store implementation
    #

    def released_version(cid)
      enabled, released_version = LandingPage.where(community_id: cid)
                                  .pluck(:enabled, :released_version)
                                  .first
      if !enabled
        raise LandingPageConfigurationError.new("Landing page not enabled. community_id: #{cid}.")
      elsif released_version.nil?
        raise LandingPageConfigurationError.new("Landing page version not specified.")
      end

      released_version
    end

    def load_structure(cid, version)
      content = LandingPageVersion.where(community_id: cid, version: version)
                .pluck(:content)
                .first
      if content.blank?
        raise LandingPageContentNotFound.new("Content missing. community_id: #{cid}, version: #{version}.")
      end

      LandingPageStoreDefaults.add_defaults(
        JSON.parse(content))
    end

    def enabled?(cid)
      if RequestStore.store.key?(:clp_enabled)
        RequestStore.store[:clp_enabled]
      else
        RequestStore.store[:clp_enabled] = _enabled?(cid)
      end
    end

    #
    # Database specific methods
    #

    def create_landing_page!(cid)
      LandingPage.create(community_id: cid)
    end

    def create_version!(cid, version_number, content)
      LandingPageVersion.create(community_id: cid, version: version_number, content: content)
    end

    def update_version!(cid, version_number, content)
      version = LandingPageVersion.where(community_id: cid, version: version_number).first
      unless version
        raise LandingPageNotFound.new("Version not found for community_id: #{cid} and version: #{version_number}.")
      end

      version.content = content
      version.save!
      lp
    end

    def release_version!(cid, version_number)
      LandingPage.transaction do
        lp = LandingPage.where(community_id: cid).first

        unless lp
          LandingPageNotFound.new("No landing page created for community_id: #{cid}.")
        end

        version = LandingPageVersion.where(community_id: cid, version: version_number).first

        unless version
          LandingPageNotFound.new("No landing page version for community_id: #{cid}, version: #{version_number}.")
        end

        version.released = Time.now
        lp.released_version = version.version
        lp.enabled = 1

        version.save!
        lp.save!
        lp
      end
    end

    # private

    def _enabled?(cid)
      enabled, released_version = LandingPage
                                  .where(community_id: cid)
                                  .pluck(:enabled, :released_version)
                                  .first
      !!(enabled && released_version)
    end
  end
end
