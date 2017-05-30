module FeatureTests
  module Navigation

    module_function

    def navigate_in_marketplace!(ident:)
      Capybara.default_host = "http://#{ident}.lvh.me:9887"
      Capybara.app_host = "http://#{ident}.lvh.me:9887"
    end
  end
end
