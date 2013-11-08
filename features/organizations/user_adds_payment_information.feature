Feature: User adds payment information
  User (organization) has to have its payment information given before organization can
  sell and receive any money

  Background:
    Given there is an organization "company"
    And "company" is a member of community "test"
    And community "test" has payments in use via Checkout
    And I am logged in as "company"

  @javascript
  Scenario: user adds payment information
    When I browse to payment settings
    And I fill the payment details form
    Then "company" should have required payment details saved to my account information

  Scenario: user views payment information
    Given "company" has Checkout account
    And I browse to payment settings
    Then I should see information about existing Checkout account

