@javascript
Feature: Inbox list of transactions


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

  Scenario: Buyer sees free transaction in list
    Given there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    Given there is a message "Love Birds" from "kassi_testperson2" about that listing
    Given I am logged in as "kassi_testperson2"
    When I go to the messages page
    Then I should see "Love Birds"

  Scenario: Buyer sees paid transaction in list
    Given there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Swinging For the Fences" about that listing
    Given I am logged in as "kassi_testperson2"
    When I go to the messages page
    Then I should see "Payment authorized: €100"
    Then I should see "About listing car spare parts"
    Then I should see "Waiting for Kassi T to accept the request. As soon as Kassi T accepts, you will be charged"

  Scenario: Buyer sees paid transaction per hour in list
    Given there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "When the Rubber Hits the Road" about that listing
    Given I am logged in as "kassi_testperson2"
    When I go to the messages page
    Then I should see "Payment authorized: €4.65"
    Then I should see "About listing Massage"
    Then I should see "Waiting for Kassi T to accept the request. As soon as Kassi T accepts, you will be charged."

  Scenario: Seller sees free transaction in list
    Given there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    Given there is a message "Love Birds" from "kassi_testperson2" about that listing
    Given I am logged in as "kassi_testperson1"
    When I go to the messages page
    Then I should see "Love Birds"

  Scenario: Seller sees paid transaction in list
    Given there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "Swinging For the Fences" about that listing
    Given I am logged in as "kassi_testperson1"
    When I go to the messages page
    Then I should see "Payment authorized: €100"
    Then I should see "About listing car spare parts"
    Then I should see "Waiting for you to accept the request"

  Scenario: Seller sees paid transaction per hour in list
    Given there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction from "kassi_testperson2" with message "When the Rubber Hits the Road" about that listing
    Given I am logged in as "kassi_testperson1"
    When I go to the messages page
    Then I should see "Payment authorized: €4.65"
    Then I should see "About listing Massage"
    Then I should see "Waiting for you to accept the request"

  Scenario: Buyer sees paid transaction with buyer commission in list
    Given there is a listing with title "Let Her Rip" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Son of a Gun" about that listing
    Given I am logged in as "kassi_testperson2"
    When I go to the messages page
    Then I should see "Payment authorized"
    Then I should see "About listing Let Her Rip"
    Then I should see "Waiting for Kassi T to accept the request. As soon as Kassi T accepts, you will be charged."

  Scenario: Buyer sees paid transaction per hour with buyer commission in list
    Given there is a listing with title "Close But No Cigar" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Cut To The Chase" about that listing
    Given I am logged in as "kassi_testperson2"
    When I go to the messages page
    Then I should see "Payment authorized"
    Then I should see "About listing Close But No Cigar"
    Then I should see "Waiting for Kassi T to accept the request. As soon as Kassi T accepts, you will be charged."

  Scenario: Seller sees paid transaction with buyer commission in list
    Given there is a listing with title "Let Her Rip" from "kassi_testperson1" with category "Items" and with listing shape "Selling For Profit"
    And the price of that listing is 100.00 EUR
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Son of a Gun" about that listing
    Given I am logged in as "kassi_testperson1"
    When I go to the messages page
    Then I should see "Payment authorized"
    Then I should see "About listing Let Her Rip"
    Then I should see "Waiting for you to accept the request"

  Scenario: Seller sees paid transaction per hour with buyer commission in list
    Given there is a listing with title "Close But No Cigar" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And the price of that listing is 1.55 EUR per hour
    And that listing availability is booking
    And that listing has default working hours
    And there is a "preauthorized" transaction with buyer commission from "kassi_testperson2" with message "Cut To The Chase" about that listing
    Given I am logged in as "kassi_testperson1"
    When I go to the messages page
    Then I should see "Payment authorized"
    Then I should see "About listing Close But No Cigar"
    Then I should see "Waiting for you to accept the request"

