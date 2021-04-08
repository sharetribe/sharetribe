module FeatureTests
  module Section
    module AdminSidebar
      extend Capybara::DSL

      module_function

      def click_payments_link
        sidebar.click_on("Payment system")
      end

      def click_paypal_link
        sidebar.click_on("PayPal settings")
      end

      def click_stripe_link
        sidebar.click_on("Stripe settings")
      end

      def sidebar
        find(".layout-container .sidenav-links")
      end
    end
  end
end
