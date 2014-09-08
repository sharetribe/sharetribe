Feature: User creates a new listing with payments

  Background:
    Given there is an organization "company"
    And "company" is a member of community "test"
    And community "test" has payments in use via Checkout
    And I am logged in as "company"

  @javascript
  Scenario: Creating a new offer with payment
    Given "company" has Checkout account
    When I create a new listing "Sledgehammer" with price
    Then I should see "Sledgehammer" within "#listing-title"
    And I should receive no emails

  @javascript
  Scenario: Creating a new offer with payment but without payment settings
    Given "company" does not have Checkout account
    When I create a new listing "Sledgehammer" with price
    Then I should see "Sledgehammer" within "#listing-title"
    And I should receive an email about missing payment details
    When I follow "payment settings" in the email
    Then I should be on the new Checkout account page
