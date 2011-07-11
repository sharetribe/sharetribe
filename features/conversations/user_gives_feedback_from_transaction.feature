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
    And I follow "Much better than expected"
    And I fill in "Textual feedback:" with "Everything was great!"
    And I press "send_testimonial_button"
    Then I should see "Feedback sent to" within "#notifications"
    And I should see "Feedback given" within ".conversation_status_label_links"
    And the system processes jobs
    When I follow "Logout"
    And I am logged in as "kassi_testperson2"
    When I follow "notifications_link"
    Then I should see "has given you feedback on event Favor offer: Massage."
    And I should see "Give feedback to"
    And I should see "see all the feedback you have received"
    And I should not see "1" within "#logged_in_notifications_icon"
  
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
  
  @javascript
  Scenario: Give neutral feedback successfully without message
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
    And I press "send_testimonial_button"
    Then I should see "Feedback sent to" within "#notifications"
    And I should see "Feedback given" within ".conversation_status_label_links"
    
  @javascript
  Scenario: Try to give non-neutral feedback without a message
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
    And I follow "Much better than expected"
    And I press "send_testimonial_button"
    Then I should see "If you want to give non-neutral feedback, you must explain why" within ".error"
  
  @javascript
  Scenario: Try to give feedback without logging in
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    When I go to the give feedback path of "kassi_testperson1"
    Then I should see "You must log in to give feedback" within "#notifications"
  
  @javascript
  Scenario: Try to give feedback on somebody else's transaction
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |
    And there is favor request with title "Massage" from "kassi_testperson3"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I go to the give feedback path of "kassi_testperson3"
    Then I should see "You are not authorized to give feedback on this event" within "#notifications"
    When I go to the give feedback path of "kassi_testperson1"
    Then I should see "You are not authorized to give feedback on this event" within "#notifications"