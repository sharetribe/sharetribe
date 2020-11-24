module FeatureTests
  module Page
    module Login
      extend Capybara::DSL

      module_function

      def fill_and_submit(username:, password:)
        fill(username: username, password: password)
        submit
      end

      def fill(username:, password:)
        page_content.fill_in("main_person_login", with: username)
        page_content.fill_in("main_person_password", with: password)
      end

      def submit
        page_content.find("#main_log_in_button").click
      end

      def page_content
        find(".page-content")
      end
    end
  end
end
