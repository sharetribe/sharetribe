Feature: User skips feedback
  In order to announce that I don't want to get feedback and thus get rid of the message stating that I haven't given feedback
  As a participant of an accepted transaction
  I want to be able to skip giving feedback

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |
    And the community has payments in use via BraintreePaymentGateway
    And Braintree escrow release is mocked
    And "kassi_testperson2" has an active Braintree account
    And there is a listing with title "Skateboard" from "kassi_testperson2" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.00 USD
    And there is a pending request "I'd like to buy a skate" from "kassi_testperson1" about that listing
    And there is a payment for that request from "kassi_testperson1" with price "20"
    And the request is confirmed
    And I am logged in as "kassi_testperson1"

  @javascript
  Scenario: Skipping feedback from the conversation page
    When I follow inbox link
    Then I should see "Waiting for you to give feedback"
    And I follow "marked the request as completed"
    And I follow "Skip feedback"
    And I should see "Feedback skipped" within ".conversation-status"
