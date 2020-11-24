@javascript
Feature: Single transaction


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

  Scenario: Buyer sees free transaction
    Given there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    Given there is a message "Drive Me Nuts" from "kassi_testperson2" about that listing
    Given I am logged in as "kassi_testperson2"
    When I visit transaction page of that listing
    Then I should see "Massage" within "h2"
    Then I should see "Drive Me Nuts" within ".message-row:nth-child(1)"

  Scenario: Buyer sees paid transaction
    Given there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Hear, Hear" about that listing
    Given I am logged in as "kassi_testperson2"
    When I visit transaction page of that listing
    Then I should see "car spare parts" within "h2"
    Then I should see "Total: €100" within ".initiate-transaction-total-wrapper"
    Then I should see "Payment authorized" within "#transaction_status"
    Then I should see "Waiting for Kassi to accept the request. As soon as Kassi accepts, you will be charged." within "#transaction_status"
    Then I should see "Payment authorized: €100" within ".message-row:nth-child(1)"
    Then I should see "Hear, Hear" within ".message-row:nth-child(2)"

  Scenario: Buyer sees paid transaction per hour
    Given there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Hands Down" about that listing
    Given I am logged in as "kassi_testperson2"
    When I visit transaction page of that listing
    Then I should see "Massage" within "h2"
    Then I should see "Price per hour: €1.55" within ".initiate-transaction-per-unit-wrapper"
    Then I should see "Booked hours: Wed, Jan 02, 2019 - 9:00 am to 12:00 pm (3 hours)" within ".initiate-transaction-booking-wrapper"
    Then I should see "Subtotal: €4.65" within ".initiate-transaction-sum-wrapper"
    Then I should see "Total: €4.65" within ".initiate-transaction-total-wrapper"
    Then I should see "Payment authorized" within "#transaction_status"
    Then I should see "Waiting for Kassi to accept the request. As soon as Kassi accepts, you will be charged." within "#transaction_status"
    Then I should see "Payment authorized: €4.65" within ".message-row:nth-child(1)"
    Then I should see "Hands Down" within ".message-row:nth-child(2)"

  Scenario: Seller sees free transaction
    Given there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    Given there is a message "Drive Me Nuts" from "kassi_testperson2" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    Then I should see "Massage" within "h2"
    Then I should see "Drive Me Nuts" within ".message-row:nth-child(1)"

  Scenario: Seller sees paid transaction
    Given there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Hear, Hear" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    Then I should see "car spare parts" within "h2"
    Then I should see "Payment total: €100" within "#tx-total-to-pay"
    Then I should see "Sharetribe fee: -€10" within "#tx-fee"
    Then I should see "Total: €90" within ".initiate-transaction-total-wrapper"
    Then I should see "Payment authorized" within "#transaction_status"
    Then I should see "Accept request" within "#transaction_status"
    Then I should see "Not this time" within "#transaction_status"
    Then I should see "Payment authorized: €100" within ".message-row:nth-child(1)"
    Then I should see "Hear, Hear" within ".message-row:nth-child(2)"

  Scenario: Seller sees paid transaction per hour
    Given there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Hands Down" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    Then I should see "Massage" within "h2"
    Then I should see "Price per hour: €1.55" within ".initiate-transaction-per-unit-wrapper"
    Then I should see "Booked hours: Wed, Jan 02, 2019 - 9:00 am to 12:00 pm (3 hours)" within ".initiate-transaction-booking-wrapper"
    Then I should see "Subtotal: €4.65" within "#tx-subtotal"
    Then I should see "Payment total: €4.65" within "#tx-total-to-pay"
    Then I should see "Sharetribe fee: -€1" within "#tx-fee"
    Then I should see "Total: €3.65" within ".initiate-transaction-total-wrapper"
    Then I should see "Payment authorized" within "#transaction_status"
    Then I should see "Accept request" within "#transaction_status"
    Then I should see "Not this time" within "#transaction_status"
    Then I should see "Payment authorized: €4.65" within ".message-row:nth-child(1)"
    Then I should see "Hands Down" within ".message-row:nth-child(2)"

  Scenario: Buyer sees paid transaction with buyer commisssion
    Given there is a listing with title "Let Her Rip" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Son of a Gun" about that listing
    Given I am logged in as "kassi_testperson2"
    When I visit transaction page of that listing
    Then I should see "Let Her Rip" within "h2"
    Then I should see "Sharetribe service fee: €15" within "#tx-buyer-fee"
    Then I should see "Total: €115" within ".initiate-transaction-total-wrapper"
    Then I should see "Payment authorized" within "#transaction_status"
    Then I should see "Waiting for Kassi to accept the request. As soon as Kassi accepts, you will be charged." within "#transaction_status"
    Then I should see "Payment authorized" within ".message-row:nth-child(1)"
    Then I should see "Son of a Gun" within ".message-row:nth-child(2)"

  Scenario: Buyer sees paid transaction per hour with buyer commisssion
    Given there is a listing with title "Close But No Cigar" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Cut To The Chase" about that listing
    Given I am logged in as "kassi_testperson2"
    When I visit transaction page of that listing
    Then I should see "Close But No Cigar" within "h2"
    Then I should see "Price per hour: €1.55" within ".initiate-transaction-per-unit-wrapper"
    Then I should see "Booked hours: Wed, Jan 02, 2019 - 9:00 am to 12:00 pm (3 hours)" within ".initiate-transaction-booking-wrapper"
    Then I should see "Subtotal: €4.65" within "#tx-subtotal"
    Then I should see "Sharetribe service fee: €1" within "#tx-buyer-fee"
    Then I should see "Total: €5.65" within ".initiate-transaction-total-wrapper"
    Then I should see "Payment authorized" within "#transaction_status"
    Then I should see "Waiting for Kassi to accept the request. As soon as Kassi accepts, you will be charged." within "#transaction_status"
    Then I should see "Payment authorized" within ".message-row:nth-child(1)"
    Then I should see "Cut To The Chase" within ".message-row:nth-child(2)"

  Scenario: Seller sees paid transaction with buyer commisssion
    Given there is a listing with title "Let Her Rip" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Son of a Gun" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    Then I should see "Let Her Rip" within "h2"
    Then I should see "Sharetribe fee: -€10" within "#tx-fee"
    Then I should see "Total: €90" within ".initiate-transaction-total-wrapper"
    Then I should see "Payment authorized" within "#transaction_status"
    Then I should see "Accept request" within "#transaction_status"
    Then I should see "Not this time" within "#transaction_status"
    Then I should see "Payment authorized" within ".message-row:nth-child(1)"
    Then I should see "Son of a Gun" within ".message-row:nth-child(2)"

  Scenario: Seller sees paid transaction per hour with buyer commisssion
    Given there is a listing with title "Close But No Cigar" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Cut To The Chase" about that listing
    Given I am logged in as "kassi_testperson1"
    When I visit transaction page of that listing
    Then I should see "Close But No Cigar" within "h2"
    Then I should see "Price per hour: €1.55" within ".initiate-transaction-per-unit-wrapper"
    Then I should see "Booked hours: Wed, Jan 02, 2019 - 9:00 am to 12:00 pm (3 hours)" within ".initiate-transaction-booking-wrapper"
    Then I should see "Subtotal: €4.65" within "#tx-subtotal"
    Then I should see "Sharetribe fee: -€1" within "#tx-fee"
    Then I should see "Total: €3.65" within ".initiate-transaction-total-wrapper"
    Then I should see "Payment authorized" within "#transaction_status"
    Then I should see "Accept request" within "#transaction_status"
    Then I should see "Not this time" within "#transaction_status"
    Then I should see "Payment authorized" within ".message-row:nth-child(1)"
    Then I should see "Cut To The Chase" within ".message-row:nth-child(2)"

