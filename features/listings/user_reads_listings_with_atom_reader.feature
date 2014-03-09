Feature: Atom feed of listings
  In order to keep updated with new listings
  As a user
  I want to follow an Atom feed of listings
  
  Scenario: Following updating Atom feed
    Given there are following users:
      | person            | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with transaction type "Selling"
    When I request the atom feed of listings
    Then I should see "car spare parts" in the feed
    When there is a listing with title "Helsinki - Turku" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
    Then I should see "car spare parts" in the feed
    And I should see "Helsinki - Turku" in the feed
