module FeatureTests
  module Page
    module NewListing
      extend Capybara::DSL

      module_function

      def fill(title, price: "", description: "")
        choose_last_shape
        choose_pickup
        new_listing_form.fill_in("listing[title]", with: title)
        new_listing_form.fill_in("listing[price]", with: price)
        new_listing_form.fill_in("listing[description]", with: description)
      end

      def save_listing
        new_listing_form.click_button("Post listing")
      end

      def new_listing_form
        find("form.new_listing")
      end

      def choose_last_shape
        if page.has_css?('.option-group[name="listing_shape"]')
          find('.option-group[name="listing_shape"]').all('a.select.option').last.click
          page.has_selector?('form.new_listing')
        end
      end

      def choose_pickup
        if page.has_css?('#pickup-checkbox')
          check('pickup-checkbox')
        end
      end
    end
  end
end
