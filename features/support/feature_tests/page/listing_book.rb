module FeatureTests
  module Page
    module ListingBook
      extend Capybara::DSL

      module_function

      def fill_in_message(message)
        page_content.fill_in("message", with: message)
      end

      def proceed_to_payment
        page_content.click_button("Proceed to payment")
      end

      def total_value
        page_content.find('.initiate-transaction-total-value')
      end

      def page_content
        find(".page-content")
      end
    end
  end
end
