@javascript
Feature: Accept Reject transaction


  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given feature flag "buyer_commission" is enabled
    Given community "test" has country "FI" and currency "EUR"
    Given community "test" has payment method "stripe" provisioned
    Given community "test" has payment method "stripe" enabled by admin
    Given community "test" has paid listing shape "Selling For Profit" "Buy For Money"
    Given community "test" has a listing shape offering services per hour
    Given I have confirmed stripe account as "kassi_testperson1"

  Scenario: Seller accepts transaction
    Given there is a listing with title "Happy as a Clam" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Cut To The Chase" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    And I follow "Accept request"
    Then I should see "Happy as a Clam" within "h3"
    Then I should see "Order by Kassi T"
    Then I should see "Subtotal: €100" within ".conversation-sum-wrapper"
    Then I should see "Sharetribe fee: -€10" within ".conversation-service-fee-wrapper"
    Then I should see "Total: €90" within ".conversation-total-wrapper"
    Then I should see "Accept" within "#send_testimonial_button"

  Scenario: Seller rejects transaction
    Given there is a listing with title "My Cup of Tea" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Lovey Dovey" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    And I follow "Not this time"
    Then I should see "My Cup of Tea" within "h3"
    Then I should see "Order by Kassi T"
    Then I should see "Subtotal: €100" within ".conversation-sum-wrapper"
    Then I should see "Sharetribe fee: -€10" within ".conversation-service-fee-wrapper"
    Then I should see "Total: €90" within ".conversation-total-wrapper"
    Then I should see "Decline" within "#send_testimonial_button"

  Scenario: Seller accepts transaction per hour
    Given there is a listing with title "No-Brainer" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 3.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Knuckle Down" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    And I follow "Accept request"
    Then I should see "No-Brainer" within "h3"
    Then I should see "Order by Kassi T"
    Then I should see "Price per hour: €3.55" within ".conversation-per-unit-wrapper"
    Then I should see "Booked hours: Wed, Jan 02, 2019 - 9:00 am to 12:00 pm (3 hours)" within ".conversation-booking-wrapper"
    Then I should see "Subtotal: €10.65" within ".conversation-sum-wrapper"
    Then I should see "Sharetribe fee: -€1.06" within ".conversation-service-fee-wrapper"
    Then I should see "Total: €9.59" within ".conversation-total-wrapper"
    Then I should see "Accept" within "#send_testimonial_button"

  Scenario: Seller rejects transaction per hour
    Given there is a listing with title "Down And Out" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 3.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Break The Ice" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    And I follow "Not this time"
    Then I should see "Down And Out" within "h3"
    Then I should see "Order by Kassi T"
    Then I should see "Price per hour: €3.55" within ".conversation-per-unit-wrapper"
    Then I should see "Booked hours: Wed, Jan 02, 2019 - 9:00 am to 12:00 pm (3 hours)" within ".conversation-booking-wrapper"
    Then I should see "Subtotal: €10.65" within ".conversation-sum-wrapper"
    Then I should see "Sharetribe fee: -€1.06" within ".conversation-service-fee-wrapper"
    Then I should see "Total: €9.59" within ".conversation-total-wrapper"
    Then I should see "Decline" within "#send_testimonial_button"

  Scenario: Seller accepts paid transaction with buyer commisssion
    Given there is a listing with title "Let Her Rip" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Son of a Gun" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    And I follow "Accept request"
    Then I should see "Let Her Rip" within "h3"
    Then I should see "Order by Kassi T"
    Then I should see "Subtotal: €100" within ".conversation-sum-wrapper"
    Then I should see "Sharetribe fee: -€10" within ".conversation-service-fee-wrapper"
    Then I should see "Total: €90" within ".conversation-total-wrapper"
    Then I should see "Accept" within "#send_testimonial_button"

  Scenario: Seller sees paid transaction per hour with buyer commisssion
    Given there is a listing with title "Close But No Cigar" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 3.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Cut To The Chase" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    And I follow "Accept request"
    Then I should see "Close But No Cigar" within "h3"
    Then I should see "Order by Kassi T"
    Then I should see "Price per hour: €3.55" within ".conversation-per-unit-wrapper"
    Then I should see "Booked hours: Wed, Jan 02, 2019 - 9:00 am to 12:00 pm (3 hours)" within ".conversation-booking-wrapper"
    Then I should see "Subtotal: €10.65" within ".conversation-sum-wrapper"
    Then I should see "Sharetribe fee: -€1.06" within ".conversation-service-fee-wrapper"
    Then I should see "Total: €9.59" within ".conversation-total-wrapper"
    Then I should see "Accept" within "#send_testimonial_button"


