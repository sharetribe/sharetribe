Feature: User rejects a transaction
  In order to announce to another user that I reject his offer or request
  As an author of a listing describing an offer or a request
  I want to be able to reject the conversation

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And the community has payments in use via BraintreePaymentGateway
    And "kassi_testperson2" has an active Braintree account
    And there is a listing with title "Skateboard" from "kassi_testperson2" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.00 USD
    And there is a pending request "I'd like to buy a skate" from "kassi_testperson1" about that listing

  @javascript
  Scenario: User rejects a request without message
    And I am logged in as "kassi_testperson2"
    When I follow inbox link
    And I follow "I'd like to buy a skate"
    And I follow "Not this time"
    And I press "Send"
    And I should see "Rejected" within ".conversation-status"
    When I follow "Skateboard"
    Then I should see "Close listing"
    When the system processes jobs
    Then "kassi_testperson1@example.com" should receive an email
    When I open the email
    Then I should see "has rejected your request" in the email body

  @javascript
  Scenario: User rejects a request with message
    And I am logged in as "kassi_testperson2"
    When I follow inbox link
    And I follow "I'd like to buy a skate"
    And I follow "Not this time"
    And I fill in "message[content]" with "Sorry, not this time."
    And I press "Send"
    And I should see "Rejected" within ".conversation-status"
    When I follow "Skateboard"
    Then I should see "Close listing"
    When the system processes jobs
    Then "kassi_testperson1@example.com" should receive an email
    When I open the email
    Then I should see "has rejected your request" in the email body
