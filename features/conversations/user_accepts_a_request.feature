Feature: User accepts a request
  In order to announce to another user that I accept his offer or request
  As an author of a listing describing an offer or a request
  I want to be able to accept the conversation

  @javascript
  Scenario: User accepts a request from the conversation page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I should see "1" within "#logged_in_messages_icon"
    And I follow "Favor offer: Massage"
    And I follow "Accept offer"
    Then I should see "Offer accepted" within "#notifications"
    And I should see "Offer accepted" within ".conversation_status_label"
    And I should not see "1" within "#logged_in_messages_icon"
  
  @javascript
  Scenario: User accepts a request from the received conversations page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I should see "1" within "#logged_in_messages_icon"
    And I should see "Favor offer: Massage" within ".unread"
    And I follow "Accept offer"
    Then I should see "Offer accepted" within "#notifications"
    And I should see "Offer accepted" within ".conversation_status_label"
    And I should not see "1" within "#logged_in_messages_icon"
    And I should not see ".unread"
  
