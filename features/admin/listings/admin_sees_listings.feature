@javascript
Feature: Admin sees list of listings


  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: List of listings
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with listing shape "Selling"
    When I go to the listings admin page
    Then I should see "car spare parts" within "#admin_listings"
    And I should see "Kassi T" within "#admin_listings"
    And I should see "Items" within "#admin_listings"
    And I should see "Open" within "#admin_listings"

  Scenario: List of listings
    And there is a listing with title "room for rent" from "kassi_testperson2" with category "Items" and with listing shape "Selling" and it is valid "20" days
    And 30 days have passed
    When I go to the listings admin page
    Then I should see "room for rent" within "#admin_listings"
    And I should see "Kassi T" within "#admin_listings"
    And I should see "Items" within "#admin_listings"
    And I should not see "Open" within "#admin_listings"
    And I should see "Expired" within "#admin_listings"
    And return to current time

