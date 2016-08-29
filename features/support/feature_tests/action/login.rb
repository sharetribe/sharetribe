module FeatureTests
  module Action
    module Login
      extend Capybara::DSL
      extend RSpec::Matchers

      module_function

      def login_as(username, password)
        topbar = FeatureTests::Section::Topbar
        login_page = FeatureTests::Page::Login

        visit("/")
        topbar.click_login_link
        login_page.fill_and_submit(username: username, password: password)
        expect(page).to have_content("Welcome")
      end

      def logout
        topbar = FeatureTests::Section::Topbar

        topbar.open_user_menu
        topbar.click_logout
        expect(page).to have_content("You have now been logged out")
      end

      def logout_and_login_as(username, password)
        logout
        login_as(username, password)
      end
    end
  end
end
