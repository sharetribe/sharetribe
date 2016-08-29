module FeatureTests
  module Section
    module AdminSidebar
      extend Capybara::DSL

      module_function

      def click_payments_link
        sidebar.click_on("Payment system")
      end

      def sidebar
        find(".left-navi")
      end
    end
  end
end
