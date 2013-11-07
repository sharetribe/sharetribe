Feature: User adds payment information
  User (organization) has to have its payment information given before organization can
  sell and receive any money

  @javascript
  Scenario: user adds payment information
    Given I am logged in as organization "company"
    And I go to settings page
    Then I should see link to payment details
    When I follow payment details link
    And I fill in payment details form
    Then I should have required payment details saved to my account information