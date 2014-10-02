Feature: Automatic transaction completition
  In order to be able to give feedback even if the buyer forgets to confirm the transaction
  As a requester
  I want that the request is automatically completed after X days

  Background:
    Given there are following users:
      | person | email              |
      | paula  | paula@example.com  |
      | jeremy | jeremy@example.com |
    And the community has payments in use via BraintreePaymentGateway
    And Braintree escrow release is mocked
    And there is a listing with title "Snowboard" from "jeremy"
    And the price of that listing is 20.00 USD
    And there is a pending request "I'd like to buy this" from "paula" about that listing
    And the request is paid

    Given I am logged in as "jeremy"
    # Using "I'm" because I don't want to hit the "I am on" step
    And I'm on the transaction page of that transaction

  @javascript
  Scenario: Transaction is automatically closed
    When "12" days have passed
    Then the requester of that conversation should receive an email about unconfirmed listing
    When "2" days have passed
    Then the requester of that conversation should receive an email about automatically confirmed listing
    Then the offerer of that conversation should receive an email confirmed listing
    When I refresh the page
    Then I should see that the conversation is confirmed
