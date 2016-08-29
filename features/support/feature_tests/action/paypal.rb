# coding: utf-8
module FeatureTests
  module Action
    module Paypal
      extend Capybara::DSL
      extend RSpec::Matchers

      module_function

      def connect_marketplace_paypal
        topbar = FeatureTests::Section::Topbar
        paypal_preferences = FeatureTests::Page::AdminPaypalPreferences
        admin_sidebar = FeatureTests::Section::AdminSidebar

        # Connect Paypal for admin
        topbar.navigate_to_admin
        admin_sidebar.click_payments_link
        paypal_preferences.connect_paypal_account

        expect(page).to have_content("PayPal account connected")

        # Save payment preferences
        paypal_preferences.set_payment_preferences("2.0", "5", "1.0")
        paypal_preferences.save_settings
        expect(page).to have_content("Payment preferences updated")
      end

      def connect_seller_paypal
        topbar = FeatureTests::Section::Topbar
        settings_sidebar = FeatureTests::Section::UserSettingsSidebar
        paypal_preferences = FeatureTests::Page::UserSettingsPayments

        # Connect Paypal for seller
        topbar.open_user_menu
        topbar.click_settings
        settings_sidebar.click_payments_link
        paypal_preferences.connect_paypal_account

        expect(page).to have_content("PayPal account connected")

        # Grant commission fee
        paypal_preferences.grant_permission

        expect(page).to have_content("Hooray, everything is set up!")
      end

      def request_listing(listing_title)
        home = FeatureTests::Page::Home
        listing = FeatureTests::Page::Listing
        listing_book = FeatureTests::Page::ListingBook
        topbar = FeatureTests::Section::Topbar

        topbar.click_logo
        home.click_listing(listing_title)
        listing.fill_in_booking_dates
        listing.click_request

        expect(page).to have_content("Request #{listing_title}")
        listing_book.fill_in_message("Snowman ☃ sells: #{listing_title}")
        listing_book.proceed_to_payment

        expect(page).to have_content("Payment authorized")
        expect(page).to have_content("Snowman ☃ sells: #{listing_title}")
      end

      def accept_listing_request
        topbar = FeatureTests::Section::Topbar

        topbar.click_inbox

        # Inbox
        expect(page).to have_content("Waiting for you to accept the request")
        page.click_link("Payment authorized")

        # Transaction conversation page
        page.click_link("Accept request")

        # Order details page
        page.click_button("Accept")
        expect(page).to have_content("Request accepted")
        expect(page).to have_content("Payment successful")
      end

      def buyer_mark_completed
        topbar = FeatureTests::Section::Topbar

        topbar.click_inbox

        # Transaction conversation page
        expect(page).to have_content("Waiting for you to mark the order completed")
        page.click_link("accepted the request, received payment for")
        page.click_link("Mark completed")

        choose("Skip feedback")
        page.click_button("Continue")

        expect(page).to have_content("Offer confirmed")
        expect(page).to have_content("Feedback skipped")
      end

      def seller_mark_completed
        topbar = FeatureTests::Section::Topbar

        topbar.click_inbox

        # Transaction conversation page
        expect(page).to have_content("Waiting for you to give feedback")
        page.click_link("marked the order as completed")
        page.click_link("Skip feedback")
        expect(page).to have_content("Feedback skipped")
      end
    end
  end
end
