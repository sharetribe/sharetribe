Feature: User skips feedback
  In order to announce that I don't want to get feedback and thus get rid of the message stating that I haven't given feedback
  As a participant of an accepted transaction
  I want to be able to skip giving feedback
  
  @javascript
  Scenario: Skipping feedback from the conversation page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Favor offer: Massage"
    And I follow "Skip feedback"
    Then I should see "Feedback skipped" within "#notifications"
    And I should see "Feedback skipped" within ".conversation_status_label_links"
    
  @javascript
  Scenario: Skipping feedback from the received conversations page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Skip feedback"
    Then I should see "Feedback skipped" within "#notifications"
    And I should see "Feedback skipped" within ".conversation_status_label_links"  
  
  

  
