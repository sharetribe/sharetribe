Feature: User cancels a transaction
  In order to mark a transaction as not happened
  As a user
  I want to be able to cancel a transaction
  
  @javascript
  Scenario: User cancels a transaction and gives feedback
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "Did not happen"
    And I click "#confirm-action-link"
    And I click "#cancel-action-link"
    And I press "Continue"
    Then I should see "Give feedback to"
    And the system processes jobs
    And "kassi_testperson2@example.com" should receive an email
    And I log out
    When I open the email
    And I should see "has canceled the request about 'Massage'" in the email body
    And I should see "Give feedback" in the email body
    
  @javascript
  Scenario: User cancels a transaction and does not give feedback
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And the offer is accepted
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "Did not happen"
    And I choose "Skip feedback"
    And I press "Continue"
    Then I should see "Feedback skipped"
  
  
  
  
  
  
  
  
