module AnalyticService
  class CommunityCustomizations < IncrementalProperties
    def process(customization)
      properties[ADMIN_CHANGED_SLOGAN] += 1 if customization.slogan_changed?
      properties[ADMIN_CHANGED_DESCRIPTION] += 1 if customization.description_changed?
    end

    private

    def default_properties
      {
        ADMIN_CHANGED_SLOGAN => 0,
        ADMIN_CHANGED_DESCRIPTION => 0
      }
    end
  end
end
