module FeatureTests
  module Action
    module Listing
      extend Capybara::DSL
      extend RSpec::Matchers

      module_function

      def add_new_listing(title:, price: "2.0")
        topbar = FeatureTests::Section::Topbar
        new_listing = FeatureTests::Page::NewListing

        topbar.click_post_a_new_listing
        new_listing.fill(title, price: price)
        new_listing.save_listing

        expect(page).to have_content("Listing created successfully.")
        expect(page).to have_content(title)

        if page.has_css?('.working-hours-form')
          find('.working-hours-form button').click
          expect(page).to have_css('.working-hours-form button.save-finished')
          click_button('side-winder-close-button')
        end
      end
    end
  end
end
