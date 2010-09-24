Feature: User gives feedback from transaction
  In order to tell another participant of the transaction how I feel about his activity in the transaction 
  As a participant of the transaction
  I want to give feedback to the another participant

  @javascript
  Scenario: Give feedback successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Give feedback"
    And I follow "As expected"
    And I fill in "Textual feedback:" with "Everything went ok."
    And I press "send_testimonial_button"
    Then I should see "Feedback sent to" within "#notifications"
    And I should see "Feedback given" within ".conversation_status_label_links"
  
  @javascript
  Scenario: Try to give feedback without giving a grade
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Give feedback"
    And I fill in "Textual feedback:" with "Everything went ok."
    And I press "send_testimonial_button"
    Then I should see "Remember to grade the user by clicking one of the icons above" within ".error"
  
  
