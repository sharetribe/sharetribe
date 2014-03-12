Feature: Automatic transaction completition

  In order to be able to give feedback even if the buyer forgets to confirm the transaction
  As a requester
  I want that the request is automatically completed after X days

  In order to get money even if the buyer forgets to confirm the transaction
  As a seller
  I want that the escrow is automatically released after X days if there are no complaints from buyer

  Background:
    Given transaction in this community are automatically completed after 14 days
    And there is an accepted conversation
    And I am on the conversation page of that listing
    Then I should see that the conversation is accepted

  Scenario: Transaction is automatically closed
    When "7" days have passed
    Then the requester of that listing should receive an email about unconfirmed listing
    When "4" days have passed
    Then the requester of that listing should receive an email about unconfirmed listing
    When "2" days have passed
    Then the requester of that listing should receive an email about unconfirmed listing
    When "1" days have passed
    Then the requester of that listing should receive an email about automatically confirmed listing
    Then the offerer of that listing should receive an email about automatically confirmed listing
    When I refresh the page
    Then I should see that the conversation was automatically confirmed

  Scenario: Transaction with escrow is automatically closed
    When "7" days have passed
    Then the buyer of that listing should receive an email about unconfirmed listing
    When "4" days have passed
    Then the buyer of that listing should receive an email about unconfirmed listing
    When "2" days have passed
    Then the buyer of that listing should receive an email about unconfirmed listing
    When "1" days have passed
    Then the buyer of that listing should receive an email about automatically confirmed listing
    Then the seller of that listing should receive an email about automatically confirmed listing
    When I refresh the page
    Then I should see that the conversation was automatically confirmed