module FeatureTests
  module Page
    module AdminPaypalPreferences
      extend Capybara::DSL

      module_function

      def payment_settings
        find(".payment-settings")
      end

      def connect_paypal_account
        payment_settings.click_link("Configure PayPal")
        payment_settings.click_button("Connect your PayPal account")
      end

      def connect_stripe_account
        payment_settings.click_link("Configure Stripe")
        payment_settings.fill_in("stripe_api_keys_form[api_publishable_key]", with: APP_CONFIG.feature_stripe_publishable_key)
        payment_settings.fill_in("stripe_api_keys_form[api_private_key]", with: APP_CONFIG.feature_stripe_private_key)
        payment_settings.click_button("Save Stripe API keys")
      end

      def change_stripe_settings
        payment_settings.click_link "config_stripe_toggle"
      end

      def change_paypal_settings
        payment_settings.click_link "config_paypal_toggle"
      end

      def edit_payment_transaction_fee_preferences(commission:, min_commission:)
        payment_settings.fill_in("payment_preferences_form[commission_from_seller]", with: commission)
        payment_settings.fill_in("payment_preferences_form[minimum_transaction_fee]", with: min_commission)
      end

      def edit_payment_general_preferences(min_price:)
        payment_settings.fill_in("payment_preferences_form[minimum_listing_price]", with: min_price)
      end

      def save_settings(title = 'Save settings')
        payment_settings.click_button(title)
      end
    end
  end
end
