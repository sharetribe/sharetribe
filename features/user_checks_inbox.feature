Feature: User checks inbox
  In order to view my received and sent messages
  As a user
  I want to be able to go to my inbox and view my messages
  
  Scenario: Viewing received messages
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    Then I should see "Messages" within "h1"
    And I should see "Favor offer: Massage" within "h3"
    And I should see "Received" within ".inbox_tab_selected"
    And I should see "Sent" within ".inbox_tab_unselected"
    And I should see "Test message" within "span"

  Scenario: Viewing sent messages
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson2"
    And there is a message "Test message" from "kassi_testperson1" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Sent"
    Then I should see "Messages" within "h1"
    And I should see "Favor offer: Massage" within "h3"
    And I should see "Test message" within "span"
  
  Scenario: Viewing a single conversation in received messages
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Favor offer: Massage"
    Then I should see "Favor offer: Massage" within "h2"  
  
  
    

  
