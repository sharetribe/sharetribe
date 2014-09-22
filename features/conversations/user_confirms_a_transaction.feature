@javascript
Feature: User confirms a transaction
  In order to be able to give feedback to the other party
  As a user
  I want to be able to confirm a transaction as happened

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And the community has payments in use via BraintreePaymentGateway
    And Braintree escrow release is mocked
    And "kassi_testperson2" has an active Braintree account
    And there is a listing with title "Skateboard" from "kassi_testperson2" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.00 USD
    And there is a pending request "I'd like to buy a skate" from "kassi_testperson1" about that listing
    And there is a payment for that request from "kassi_testperson1" with price "20"
    And the request is paid
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    Then I should see "Waiting for you to mark the request completed"
    When I follow "paid $20"
    And I follow "Mark completed"

  Scenario: User confirms and gives feedback
    And I click "#cancel-action-link"
    And I click "#confirm-action-link"
    And I press "Continue"
    Then I should see "Give feedback to"
    And the system processes jobs
    And "kassi_testperson2@example.com" should receive 2 emails
    And I log out
    When I open the email with subject "Request completed"
    And I should see "has marked the request about 'Skateboard' completed" in the email body
    And I should see "Give feedback" in the email body
    When "4" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    When I open the email with subject "Reminder: remember to give feedback to"
    Then I should see "You have not yet given feedback to" in the email body
    When "4" days have passed
    Then "kassi_testperson2@example.com" should have 3 emails
    When "8" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 4 emails
    When "100" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 4 emails
    And return to current time

  Scenario: User confirms a transaction and does not give feedback
    And I choose "Skip feedback"
    And I press "Continue"
    Then I should see "Feedback skipped"
