# Note: this feature tests only transactions that do not involve payments. 
# Accepting transactions with payments are tested in gateway-specific features in payments folder.
Feature: User accepts a transaction
  In order to announce to another user that I accept his offer or request
  As an author of a listing describing an offer or a request
  I want to be able to accept the conversation

  @javascript
  Scenario: User accepts a non-payment-requiring request without message
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
    And there is a message "I request this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    Then I should see "1" within ".inbox-link"
    When I follow "Accept request"
    And I press "Send"
    Then I should see "Accepted" 
    And I should see "to mark the request as completed" within ".conversation-status"
    When I follow "Massage"
    Then I should not see "Listing is closed"
    And I should see "Close listing"
    And the system processes jobs
    When "8" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 2 emails
    Then I should receive an email with subject "Your request was accepted"
    Then I should receive an email with subject "Remember to confirm or cancel a request"
    When I open the email with subject "Remember to confirm"
    Then I should see "You have not yet confirmed" in the email body
    When "16" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    Then I should receive an email with subject "Request automatically completed - remember to give feedback"
    When "100" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 4 emails
    Then I should receive an email with subject "Reminder: remember to give feedback"
    And return to current time
  