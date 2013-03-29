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
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "conversation_title_link_1"
    And I follow "Not this time"
    And I press "Send message"
    Then I should see "Offer rejected"
    And I should see "Offer rejected" within ".conversation-status"
    When I follow "Massage"
    Then I should see "Request is closed"
    Then I should not see "Close request"
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
    And there is favor offer with title "Massage" from "kassi_testperson1"
    And there is a message "I request this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "Not this time"
    And I choose "Update the listing later"
    And I fill in "conversation_message_attributes_content" with "Sorry, not this time."
    And I press "Send message"
    And I should see "Request rejected" within ".conversation-status"
    And I should see "Sorry, not this time."
    When I follow "Massage"
    Then I should not see "Offer is closed"
    And I should see "Close offer"