module FeatureTests
  module Page
    module UserSettingsPayments
      extend Capybara::DSL

      module_function

      def payment_settings
        find(".payment-settings")
      end

      def connect_paypal_account
        payment_settings.click_button("Connect your PayPal account")
      end

      def save_settings
        payment_settings.click_button("Save settings")
      end

      def grant_permission
        payment_settings.click_button("Grant permission")
      end
    end
  end
end
