Feature: User views profile page
  In order to find information about a user
  As a user
  I want to 

  Scenario: User views his own profile page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing offer with title "Housing" from "kassi_testperson2" and with share type "sell"
    And I am logged in as "kassi_testperson1"
    When I follow "profile"
    Then I should see "car spare parts"
    And I should see "Helsinki - Turku"
    And I should not see "Housing"
    And I should not see "massage"
    And I should see "Offers (2)" within ".inbox_tab_selected"
    And I should see "Requests (1)" within ".inbox_tab_unselected"
  
  Scenario: User checks user's requests from the profile page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing offer with title "Housing" from "kassi_testperson2" and with share type "sell"
    And I am logged in as "kassi_testperson1"
    When I follow "profile"
    And I follow "Requests (1)"
    Then I should not see "car spare parts"
    And I should not see "Helsinki - Turku"
    And I should not see "Housing"
    And I should see "massage"
    And I should see "Offers (2)" within ".inbox_tab_unselected"
    And I should see "Requests (1)" within ".inbox_tab_selected" 
  
  Scenario: User views somebody else's profile page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing offer with title "Housing" from "kassi_testperson2" and with share type "sell"
    And I am not logged in
    And I am on the home page
    When I follow "car spare parts"
    And I follow "listing_author"
    Then I should see "car spare parts"
    And I should see "Helsinki - Turku"
    And I should not see "Housing"
    And I should not see "massage"
    And I should see "Offers (2)" within ".inbox_tab_selected"
    And I should see "Requests (1)" within ".inbox_tab_unselected"
  
  
  
  
  
