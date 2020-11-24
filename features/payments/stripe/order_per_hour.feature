@javascript
Feature: Buyer initiate order and pays for listing per hour

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    # If tests failed then set current time in the furure!
    And it is currently "2050-11-28 05:00:00"
    Given feature flag "buyer_commission" is enabled
    Given community "test" has payment method "stripe" provisioned
    Given community "test" has payment method "stripe" enabled by admin
    Given Stripe API is fake
    Given community "test" has a listing shape offering services per hour
    Given I have confirmed stripe account as "kassi_testperson1"
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 USD per hour
    And that listing availability is booking
    And that listing has default working hours

  Scenario: Buyer buyes listing per hour
    When I am logged in as "kassi_testperson2"
    And I go to the listing page
    When I focus on "#start-on"
    Then I should see "November 2050"
    When I click on datepicker day "28"
    Then I select "9:00 am" from "start_time"
    Then I select "12:00 pm" from "end_time"
    When I press "Request"
    Then I should see "Booked hours: Mon, Nov 28, 2050 - 9:00 am to 12:00 pm (3 hours)"
    Then I should see "Price per hour: $1.55"
    Then I should see "Subtotal: $4.65"
    Then I should see "Total: $4.65"
    And I pay with stripe
    Then I should see "Payment authorized"
    Then I should see "Booked hours: Mon, Nov 28, 2050 - 9:00 am to 12:00 pm (3 hours)"
    Then I should see "Price per hour: $1.55"
    Then I should see "Subtotal: $4.65"
    Then I should see "Total: $4.65"

  Scenario: Buyer buyes listing per hour with buyer fee 10%
    Given community "test" payment gateway stripe has buyer fee "10"%
    When I am logged in as "kassi_testperson2"
    And I go to the listing page
    When I focus on "#start-on"
    Then I should see "November 2050"
    When I click on datepicker day "28"
    Then I select "9:00 am" from "start_time"
    Then I select "12:00 pm" from "end_time"
    When I press "Request"
    Then I should see "Booked hours: Mon, Nov 28, 2050 - 9:00 am to 12:00 pm (3 hours)"
    Then I should see "Price per hour: $1.55"
    Then I should see "Subtotal: $4.65"
    Then I should see "Sharetribe service fee: $0.46"
    Then I should see "Total: $5.11"
    And I pay with stripe
    Then I should see "Payment authorized"
    Then I should see "Booked hours: Mon, Nov 28, 2050 - 9:00 am to 12:00 pm (3 hours)"
    Then I should see "Price per hour: $1.55"
    Then I should see "Subtotal: $4.65"
    Then I should see "Sharetribe service fee: $0.46"
    Then I should see "Total: $5.11"

