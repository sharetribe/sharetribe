Feature: Automatic transaction completition

  In order to be able to give feedback even if the buyer forgets to confirm the transaction
  As a requester
  I want that the request is automatically completed after X days

  In order to get money even if the buyer forgets to confirm the transaction
  As a seller
  I want that the escrow is automatically released after X days if there are no complaints from buyer

  Background:
    Given there are following users:
    | person |
    | paula  |
    | jeremy |
    Given I am logged in as "paula"
    And transaction in this community are automatically completed after 14 days
    And there is a listing with title "Snowboard" from "jeremy"
    And there is a message "I'd like to buy this" from "paula" about that listing
    And the request is accepted
    And I'm on the conversation page of that conversation
    Then I should see that the conversation is waiting for confirmation

  @javascript
  Scenario: Transaction is automatically closed
    When "12" days have passed
    Then the requester of that listing should receive an email about unconfirmed listing
    When "2" days have passed
    Then the requester of that listing should receive an email about automatically confirmed listing
    Then the offerer of that listing should receive an email confirmed listing
    When I refresh the page
    Then I should see that the conversation is confirmed

  @javascript
  Scenario: Transaction with escrow is automatically closed
    When "12" days have passed
    Then the buyer of that listing should receive an email about unconfirmed listing
    When "2" days have passed
    Then the buyer of that listing should receive an email about automatically confirmed listing
    Then the offerer of that listing should receive an email confirmed listing
    When I refresh the page
    Then I should see that the conversation is confirmed