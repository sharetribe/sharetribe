@javascript
Feature: User books listing per hour

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    # If tests failed then set current time in the furure!
    And it is currently "2050-11-28 05:00:00"
    Given community "test" has payment method "paypal" provisioned
    Given community "test" has payment method "paypal" enabled by admin
    Given community "test" has a listing shape offering services per hour
    Given I have confirmed paypal account as "kassi_testperson1"
    Given I have confirmed paypal account as "kassi_testperson2"
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 USD per hour
    And that listing availability is booking
    And that listing has default working hours

  Scenario: Reach payment step successfully
    When I am logged in as "kassi_testperson2"
    And I am on the home page
    And I follow "Massage"
    Then I should see "Massage"
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

  Scenario: Reach payment step successfully at end of working hours
    When I am logged in as "kassi_testperson2"
    And I am on the home page
    And I follow "Massage"
    Then I should see "Massage"
    When I focus on "#start-on"
    Then I should see "November 2050"
    When I click on datepicker day "28"
    Then I select "3:00 pm" from "start_time"
    Then I select "5:00 pm" from "end_time"
    When I press "Request"
    Then I should see "Booked hours: Mon, Nov 28, 2050 - 3:00 pm to 5:00 pm (2 hours)"
    Then I should see "Price per hour: $1.55"
    Then I should see "Subtotal: $3.10"
    Then I should see "Total: $3.10"

  Scenario: Reach payment step successfully when booking is among another bookings
    Given that listing have booking at "2050-11-28" from "09:00" till "10:00"
    Given that listing have booking at "2050-11-28" from "11:00" till "12:00"
    When I am logged in as "kassi_testperson2"
    And I am on the home page
    And I follow "Massage"
    Then I should see "Massage"
    When I focus on "#start-on"
    Then I should see "November 2050"
    When I click on datepicker day "28"
    Then I select "10:00 am" from "start_time"
    Then I select "11:00 am" from "end_time"
    When I press "Request"
    Then I should see "Booked hour: Mon, Nov 28, 2050 - 10:00 am to 11:00 am (1 hour)"
    Then I should see "Price per hour: $1.55"
    Then I should see "Total: $1.55"

  Scenario: Reach payment step successfully. Transaction agreement in use.
    Given this community has transaction agreement in use
    When I am logged in as "kassi_testperson2"
    And I am on the home page
    And I follow "Massage"
    Then I should see "Massage"
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

