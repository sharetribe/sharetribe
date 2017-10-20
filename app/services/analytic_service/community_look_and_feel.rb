module AnalyticService
  class CommunityLookAndFeel < IncrementalProperties

    def process(orig_community, params)
      community = Community.find(orig_community.id)
      community.assign_attributes(params)
      properties[ADMIN_CHANGED_COVER_PHOTO] += 1 if community.cover_photo_file_name_changed?
    end

    private

    def default_properties
      {
        ADMIN_CHANGED_COVER_PHOTO => 0
      }
    end
  end
end
