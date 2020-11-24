module FeatureTests
  module Section
    module UserSettingsSidebar
      extend Capybara::DSL

      module_function

      def click_payments_link
        sidebar.click_link("Payments")
      end

      def sidebar
        find(".left-navi")
      end
    end
  end
end
