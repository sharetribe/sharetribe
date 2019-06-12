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
        select("United States", from: "stripe_account_form_address_country")

        payment_settings.fill_in("stripe_account_form[first_name]", with: "Jane")
        payment_settings.fill_in("stripe_account_form[last_name]", with: "Seller")

        payment_settings.fill_in("stripe_account_form[phone]", with: "+1 (555) 123-12345")

        select("1990", from: "stripe_account_form_birth_date_1i")
        select("October", from: "stripe_account_form_birth_date_2i")
        select("12", from: "stripe_account_form_birth_date_3i")

        select("New York", from: "stripe_account_form_address_state")
        payment_settings.fill_in("stripe_account_form[address_city]", with: "New York")
        payment_settings.fill_in("stripe_account_form[address_postal_code]", with: "01001")
        payment_settings.fill_in("stripe_account_form[address_line1]", with: "123 Street")
        payment_settings.fill_in("stripe_account_form[ssn_last_4]", with: '1234')

        payment_settings.fill_in("stripe_bank_form[bank_account_number]", with: "000123456789")
        payment_settings.fill_in("stripe_bank_form[bank_routing_number]", with: "110000000")

        payment_settings.click_button("Save details")
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
