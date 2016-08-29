module FeatureTests
  module Page
    module ListingBook
      extend Capybara::DSL

      module_function

      def fill_in_message(message)
        page_content.fill_in("listing_conversation[content]", with: message)
      end

      def proceed_to_payment
        page_content.click_button("Proceed to payment")
      end

      def page_content
        find(".page-content")
      end
    end
  end
end
