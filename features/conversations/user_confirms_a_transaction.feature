Feature: User confirms a transaction
  In order to be able to give feedback to the other party
  As a user
  I want to be able to confirm a transaction as happened
  
  @javascript
  Scenario: User confirms and gives feedback
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "Mark completed"
    And I click "#cancel-action-link"
    And I click "#confirm-action-link"
    And I press "Continue"
    Then I should see "Give feedback to"
    And the system processes jobs
    And "kassi_testperson2@example.com" should receive an email
    And I log out
    When I open the email
    And I should see "has marked the request about 'Massage' completed" in the email body
    And I should see "Give feedback" in the email body
    When "4" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 2 emails
    When I open the email with subject "Reminder: remember to give feedback to"
    Then I should see "You have not yet given feedback to" in the email body
    When "4" days have passed
    Then "kassi_testperson2@example.com" should have 2 emails
    When "8" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    When "100" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    And return to current time
    
  @javascript
  Scenario: User confirms a transaction and does not give feedback
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "Mark completed"
    And I choose "Skip feedback"
    And I press "Continue"
    Then I should see "Feedback skipped"
  
  
  
  
  
  
  
  
