module CustomLandingPage
  module LandingPageStore

    class LandingPage < ActiveRecord::Base; end
    class LandingPageVersion < ActiveRecord::Base; end

    module_function

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

      JSON.parse(content)
    end

    def enabled?(cid)
      enabled, released_version = LandingPage
                                  .where(community_id: cid)
                                  .pluck(:enabled, :released_version)
                                  .first
      !!(enabled && released_version)
    end
  end
end
