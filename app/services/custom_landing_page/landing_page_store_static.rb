module CustomLandingPage
  class LandingPageStoreStatic

    def initialize(released_version)
      @_released_version = released_version || 1
    end

    def released_version(*)
      @_released_version
    end

    def load_structure(*)
      data = if CustomLandingPage.const_defined?("StaticData")
               CustomLandingPage::StaticData::DATA_STR
             else
               CustomLandingPage::ExampleData::DATA_STR
             end
      LandingPageStoreDefaults.add_defaults(JSON.parse(data))
    end

    def enabled?(cid)
      true
    end
  end
end
