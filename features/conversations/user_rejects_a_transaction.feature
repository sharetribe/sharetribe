Feature: User rejects a transaction
  In order to announce to another user that I reject his offer or request
  As an author of a listing describing an offer or a request
  I want to be able to reject the conversation

  @javascript
  Scenario: User rejects an offer without message and closes the listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "I offer this"
    And I follow "Not this time"
    And I press "Send"
    And I should see "Rejected" within ".conversation-status"
    When I follow "Massage"
    Then I should see "Close listing"
    When the system processes jobs
    Then "kassi_testperson2@example.com" should receive an email
    When I open the email
    Then I should see "has rejected your offer" in the email body
  
  @javascript
  Scenario: User rejects a request with message and does not close the listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Selling services"
    And there is a message "I request this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "Not this time"
    And I fill in "conversation_message_attributes_content" with "Sorry, not this time."
    And I press "Send"
    And I should see "Rejected" within ".conversation-status"
    And I should see "Sorry, not this time."
    When I follow "Massage"
    Then I should not see "Listing is closed"
    And I should see "Close listing"