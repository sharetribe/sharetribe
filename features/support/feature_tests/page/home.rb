module FeatureTests
  module Page
    module Home
      extend Capybara::DSL

      module_function

      def click_listing(title)
        page_content.find(".fluid-thumbnail-grid-image-title", text: title).click
      end

      def page_content
        find(".page-content")
      end
    end
  end
end
