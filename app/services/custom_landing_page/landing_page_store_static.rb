module CustomLandingPage
  class LandingPageStoreStatic

    def initialize(released_version)
      @_released_version = released_version || 1
    end

    def released_version(*)
      @_released_version
    end

    def load_structure(*)
      JSON.parse(File.read(Rails.root.join('db','clp_data.json'))) #CustomLandingPage::ExampleData::DATA_STR)
    end

    def enabled?(cid)
      true
    end
  end
end
