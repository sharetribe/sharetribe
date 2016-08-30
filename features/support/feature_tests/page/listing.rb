module FeatureTests
  module Page
    module Listing
      extend Capybara::DSL

      module_function

      def fill_in_booking_dates

        # Select the last available day in the current month
        page_content.find("input[name=start_on]").click
        datepicker.all(".day:not(.disabled):not(.new)").last.click

        # Select the first available day in the following month
        page_content.find("input[name=end_on]").click
        datepicker.find(".next").click
        datepicker.first(".day:not(.disabled):not(.old)").click

        find(".listing-title").click
      end

      def click_request
        page_content.click_button("Request")
      end

      def datepicker
        find(".datepicker")
      end

      def page_content
        find(".page-content")
      end
    end
  end
end
