module FeatureTests
  module Section
    module OnboardingWizard
      extend Capybara::DSL
      extend RSpec::Matchers

      module_function

      def dismiss_dialog
        expect(page).to have_content("Woohoo, task completed!")
        page.click_on("I'll do it later, thanks")
      end

    end
  end
end
