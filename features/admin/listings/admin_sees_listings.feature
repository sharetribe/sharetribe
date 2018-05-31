@javascript
Feature: Admin sees list of listings


  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with listing shape "Selling"

  Scenario: Admin user can enable or disable payment method
    When I go to the listings admin page
    Then I should see "car spare parts" within "#admin_listings"
    And I should see "Kassi T" within "#admin_listings"
    And I should see "Items" within "#admin_listings"
    And I should see "Open" within "#admin_listings"

