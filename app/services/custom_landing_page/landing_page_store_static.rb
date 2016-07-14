module CustomLandingPage
  class LandingPageStoreStatic

    def initialize(released_version)
      @_released_version = released_version || 1
    end

    def released_version(*)
      @_released_version
    end

    def load_structure(*)
      JSON.parse(CustomLandingPage::ExampleData::DATA_STR)
    end

    def enabled?(cid)
      true
    end
  end
end
