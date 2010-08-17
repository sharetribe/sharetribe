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
    And I follow "Favor offer: Massage"
    And I follow "Accept offer"
    Then I should see "Offer accepted" within "#notifications"
    And the status of the conversation should be "accepted"
    And I should see "Offer accepted" within ".conversation_status_label"
    And I should be in the conversation page of "kassi_testperson1"
  
