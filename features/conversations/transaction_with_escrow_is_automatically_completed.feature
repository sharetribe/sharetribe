Feature: Automatic transaction with escrow completition
  In order to get money even if the buyer forgets to confirm the transaction
  As a seller
  I want that the escrow is automatically released after X days if there are no complaints from buyer

  Background:
    Given there are following users:
      | person |
      | paula  |
      | jeremy |

    Given community "test" has payments in use via BraintreePaymentGateway
    And Braintree escrow release is mocked
    And there is a listing with title "Snowboard" from "jeremy"
    And the price of that listing is 12.00 USD
    And there is a pending request "I'd like to buy this" from "paula" about that listing
    And the request is paid

    Given I am logged in as "jeremy"
    # Using "I'm" because I don't want to hit the "I am on" step
    And I'm on the transaction page of that transaction

  @javascript
  Scenario: Transaction with escrow is automatically closed
    When "12" days have passed
    Then the buyer of that conversation should receive an email about unconfirmed listing with escrow
    When "2" days have passed
    Then the buyer of that conversation should receive an email about automatically confirmed listing
    Then the seller of that conversation should receive an email confirmed listing
    When I refresh the page
    Then I should see that the conversation is confirmed
