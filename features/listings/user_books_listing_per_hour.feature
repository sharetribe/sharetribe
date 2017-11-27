@javascript
Feature: User books listing per hour

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given community "test" has feature flag "availability_per_hour" enabled
    Given community "test" has payment method "paypal" provisioned
    Given community "test" has payment method "paypal" enabled by admin
    Given community "test" has a listing shape offering services per hour
    Given I have confirmed paypal account as "kassi_testperson1"
    Given I have confirmed paypal account as "kassi_testperson2"
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 USD per hour
    And that listing availability is booking
    And that listing has default working hours
    And it is currently "2017-11-27 05:00:00"

  Scenario: Reach payment step successfully
    When I am logged in as "kassi_testperson2"
    And I am on the home page
    And I follow "Massage"
    Then I should see "Massage"
    When I focus on "#start-on"
    Then I should see "November 2017"
    When I click on datepicker day "27"
    Then I select "9:00 am" from "start_time"
    Then I select "12:00 pm" from "end_time"
    When I press "Request"
    Then I should see "Booked hours: Mon, Nov 27, 2017 - 9:00 am to 12:00 pm (3 hours)"
    Then I should see "Price per hour: $1.55"
    Then I should see "Subtotal: $4.65"
    Then I should see "Total: $4.65"

