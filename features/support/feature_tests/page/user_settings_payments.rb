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

      def connect_stripe_account
        payment_settings.fill_in("stripe_account_form[first_name]", with: "Jane")
        payment_settings.fill_in("stripe_account_form[last_name]", with: "Seller")
        payment_settings.fill_in("stripe_account_form[birth_date]", with: "1/1/1990")
        payment_settings.fill_in("stripe_account_form[ssn_last_4]", with: "1234")

        execute_script("$('#stripe_account_form_address_country').val('US')")
        payment_settings.fill_in("stripe_account_form[address_state]", with: "NY")
        payment_settings.fill_in("stripe_account_form[address_city]", with: "New York")
        payment_settings.fill_in("stripe_account_form[address_postal_code]", with: "01001")
        payment_settings.fill_in("stripe_account_form[address_line1]", with: "123 Street")

        payment_settings.fill_in("stripe_bank_form[bank_account_number]", with: "000123456789")
        payment_settings.fill_in("stripe_bank_form[bank_routing_number]", with: "110000000")

        payment_settings.click_button("Save Details")
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
