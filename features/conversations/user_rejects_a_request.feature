Feature: User rejects a request
  In order to announce to another user that I reject his offer or request
  As an author of a listing describing an offer or a request
  I want to be able to reject the conversation

  @javascript
  Scenario: User rejects a request from the conversation page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "Service offer: Massage"
    And I follow "Not this time"
    Then I should see "Offer rejected"
    And I should see "Offer rejected" within ".conversation-status"
  
  @javascript
  Scenario: User rejects a request from the received conversations page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "I offer this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    And I follow "Not this time"
    And I should see "Offer rejected" within ".conversation-status"