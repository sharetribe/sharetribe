module CustomLandingPage
  class LandingPageStoreStatic

    def initialize(released_version)
      @_released_version = released_version || 1
    end

    def released_version(*)
      @_released_version
    end

    def load_structure(*)
      structure = LandingPageStoreDefaults.add_defaults(
        JSON.parse(CustomLandingPage::ExampleData::DATA_STR))
      
      begin
        structure = JSON.parse(CustomLandingPage::StaticData::DATA_STR)
      rescue NameError
      end

      structure
    end

    def enabled?(cid)
      true
    end
  end
end
