Feature: User gives feedback from transaction
  In order to tell another participant of the transaction how I feel about his activity in the transaction
  As a participant of the transaction
  I want to give feedback to the another participant

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

  @javascript
  Scenario: Give feedback successfully
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    Then I should see "Waiting for you to give feedback"
    And I follow "marked the request as completed"
    And I follow "Give feedback"
    And I click "#positive-grade-link"
    And I fill in "How did things go?" with "Everything was great!"
    And I press "send_testimonial_button"
    Then I should see "Feedback sent to" within ".flash-notifications"
    And I should see "Feedback given" within ".conversation-status"
    And I log out
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    When I open the email with subject "has given you feedback"
    Then I should see "has given you feedback" in the email body
    When I follow "View feedback" in the email
    Then I should see "Everything was great!"
    When I open the email with subject "has given you feedback"
    And I follow "Give feedback" in the email
    And I log in as "kassi_testperson2"
    Then I should see "How did things go?"

  @javascript
  Scenario: Try to give feedback without required information
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    Then I should see "Waiting for you to give feedback"
    And I follow "marked the request as completed"
    And I follow "Give feedback"
    And I press "send_testimonial_button"
    Then I should see "Remember to tell whether your experience was positive or negative."
    And I should see "This field is required"

  @javascript
  Scenario: Try to give feedback without logging in
    When I go to the give feedback path of "kassi_testperson1"
    Then I should see "You must log in to give feedback" within ".flash-notifications"

  @javascript
  Scenario: Try to give feedback on somebody else's transaction
    And I am logged in as "kassi_testperson3"
    When I go to the give feedback path of "kassi_testperson1"
    Then I should see "You are not authorized to give feedback on this event" within ".flash-notifications"
