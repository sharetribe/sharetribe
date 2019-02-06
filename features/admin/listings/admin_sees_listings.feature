Feature: Admin sees list of listings

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given "kassi_testperson1" has admin rights in community "test"

  @javascript
  Scenario: List of listings
    Given community "test" has new order type "Selling2" with action button "Buy"
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with listing shape "Selling2"
    And I am logged in as "kassi_testperson1"
    When I go to the listings admin page
    Then I should see "car spare parts" within "#admin_listings"
    And I should see "Kassi T" within "#admin_listings"
    And I should see "Items" within "#admin_listings"
    And I should see "Open" within "#admin_listings"

  @javascript
  Scenario: List of listings
    Given community "test" has new order type "Selling2" with action button "Buy"
    And there is a listing with title "room for rent" from "kassi_testperson2" with category "Items" and with listing shape "Selling2" and it is valid "20" days
    And 30 days have passed
    And I am logged in as "kassi_testperson1"
    When I go to the listings admin page
    Then I should see "room for rent" within "#admin_listings"
    And I should see "Kassi T" within "#admin_listings"
    And I should see "Items" within "#admin_listings"
    And I should not see "Open" within "#admin_listings"
    And I should see "Expired" within "#admin_listings"
    And return to current time

