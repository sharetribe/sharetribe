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
    When I browse to Checkout account settings
    And I fill the payment details form
    Then "company" should have required Checkout payment details saved to my account information

  @javascript
  Scenario: user does not add required information
    When I browse to Checkout account settings
    And I press submit
    Then I should see 2 validation errors

  @javascript
  Scenario: user adds invalid information
    When I browse to Checkout account settings
    And I fill the payment details form with invalid information
    Then I should see flash error

  @javascript
  Scenario: user views payment information
    Given "company" has Checkout account
    And I am on the settings page
    And I follow "Payments"
    Then I should see information about existing Checkout account
