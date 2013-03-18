Feature: User accepts a transaction
  In order to announce to another user that I accept his offer or request
  As an author of a listing describing an offer or a request
  I want to be able to accept the conversation

  @javascript
  Scenario: User accepts an offer and closes the listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I should see "1" within ".inbox-toggle"
    And I follow "Service offer: Massage"
    And I follow "Accept offer"
    And I fill in "Message" with "Ok, sounds good!"
    And I choose "I'll update the listing later"
    And I follow "Send message"
    Then I should see "Offer accepted" within ".conversation-status"
    And the system processes jobs
    And "kassi_testperson2@example.com" should receive an email
    And "kassi_testperson1@example.com" should not receive an email
    When I follow "Massage"
    Then I should see "Request closed"
    When 8 days have passed
    And the system processes jobs
    Then "kassi_testperson1@example.com" should receive an email
    When I open the email
    And return to current time
  
  @javascript
  Scenario: User accepts a request and doesn't close the listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor offer with title "Massage" from "kassi_testperson1"
    And there is a message "I request this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I should see "1" within ".inbox-toggle"
    And I should see "Service offer: Massage" within ".unread"
    When I follow "Accept offer"
    Then I should see "Offer accepted" within ".conversation-status"
    And I should not see "1" within ".inbox-toggle"
    And I should not see ".unread"
    When I follow "Massage"
    Then I should not see "Request closed"
  
