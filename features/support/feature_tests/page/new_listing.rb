module FeatureTests
  module Page
    module NewListing
      extend Capybara::DSL

      module_function

      def fill(title, price: "", description: "")
        new_listing_form.fill_in("listing[title]", with: title)
        new_listing_form.fill_in("listing[price]", with: price)
        new_listing_form.fill_in("listing[description]", with: description)
      end

      def save_listing
        new_listing_form.click_button("Save listing")
      end

      def new_listing_form
        find("form.new_listing")
      end
    end
  end
end
