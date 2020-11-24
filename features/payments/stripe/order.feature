@javascript
Feature: Buyer initiate order and pays


  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given feature flag "buyer_commission" is enabled
    Given community "test" has country "FI" and currency "EUR"
    Given community "test" has payment method "stripe" provisioned
    Given community "test" has payment method "stripe" enabled by admin
    Given Stripe API is fake
    Given community "test" has paid listing shape "Selling For Profit" "Buy For Money"
    Given I have confirmed stripe account as "kassi_testperson1"
    Given I am logged in as "kassi_testperson2"

  Scenario: Buyer buyes listing
    Given there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And I go to the listing page
    When I press "Buy For Money"
    When I fill in "message" with "Hallo Sally"
    And I pay with stripe
    Then I should see "Payment authorized"
    And I should see "Total: €100"
    And I should see "Hallo Sally"

  Scenario: Buyer buyes listing with buyer fee 10%
    Given there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    Given community "test" payment gateway stripe has buyer fee "10"%
    And the price of that listing is 100.00 EUR
    And I go to the listing page
    When I press "Buy For Money"
    Then I should see "Sharetribe service fee: €10"
    Then I should see "Total: €110"
    And I pay with stripe
    Then I should see "Payment authorized"
    Then I should see "Total: €110"

