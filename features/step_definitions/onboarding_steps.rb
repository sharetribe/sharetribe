# coding: utf-8

Then("I dismiss the onboarding wizard") do
  onboarding_wizard = FeatureTests::Section::OnboardingWizard
  onboarding_wizard.dismiss_dialog
end
