module FeatureTests
  module Section
    module Topbar
      extend Capybara::DSL

      module_function

      def click_login_link
        header.click_link("Log in")
      end

      def navigate_to_admin
        open_menu
        click_admin_link
      end

      def open_menu
        header.find("span", text: "Menu").click
      end

      def open_user_menu
        header.find(".header-user-toggle").click
      end

      def user_menu
        header.find(".header-toggle-menu-user")
      end

      def click_settings
        user_menu.click_link("Settings")
      end

      def click_logout
        user_menu.click_link("Log out")
      end

      def click_admin_link
        header.click_link("Admin")
      end

      def click_post_a_new_listing
        header.click_link("Post a new listing")
      end

      def click_inbox
        header.find("#inbox-link").click
      end

      def click_logo
        header.find(".header-logo").click
      end

      def header
        find(".header")
      end
    end
  end
end
