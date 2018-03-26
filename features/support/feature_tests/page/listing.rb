module FeatureTests
  module Page
    module Listing
      extend Capybara::DSL

      module_function

      def fill_in_booking_dates
        if page.has_css?("input[name=start_on]")
          # Select the last available day in the current month
          page_content.find("input[name=start_on]").click
          datepicker.all(".day:not(.disabled):not(.new)").last.click

          # Select the first available day in the following month
          page_content.find("input[name=end_on]").click
          datepicker.find(".next").click
          datepicker.first(".day:not(.disabled):not(.old)").click

          find(".listing-title").click
        elsif page.has_css?("#start_time")
          page_content.find("#start-on").click
          find('.datepicker-days .day:not(.disabled)', text: '28', match: :prefer_exact).click
          select('9:00 am', :from => 'start_time')
          select('12:00 am', :from => 'end_time')
        end
      end

      def click_request
        page_content.click_button("Buy")
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
