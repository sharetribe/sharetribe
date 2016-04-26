Feature: User changes email address
  In order to change the email address associated with me in Sharetribe
  As a user
  I want to be able to change my email address

  Background:
    Given there are following communities:
      | community             | allowed_emails |
      | testcommunity         | @example.com   |
    And there are following users:
      | person      | community     |
      | sharetribe1 | testcommunity |
    And there are following emails:
      | person      | address                 | send_notifications | confirmed_at        |
      | sharetribe1 | sharetribe@example.com  | false              | 2013-11-14 20:02:23 |
      | sharetribe1 | sharetribe2@example.com | true               | 2013-11-14 20:02:23 |
      | sharetribe1 | sharetribe@gmail.com    | false              | 2013-11-14 20:02:23 |
      | sharetribe1 | sharetribe@yahoo.com    | false              | nil                 |
    When I move to community "testcommunity"
    And I am logged in as "sharetribe1"
    And I am on the account settings page

  @javascript
  Scenario: User adds a new email (and confirms it)
    When I add a new email "sharetribe1-2@example.com"
    Then I should have unconfirmed email "sharetribe1-2@example.com"
    When I confirm email address "sharetribe1-2@example.com"
    Then I should have confirmed email "sharetribe1-2@example.com"

  @javascript
  Scenario: User removes an email
    Given I will confirm all following confirmation dialogs in this page if I am running PhantomJS
    Then I should not be able to remove email "sharetribe2@example.com"
    When I remove email "sharetribe@example.com"
    Then I should not have email "sharetribe@example.com"

  @javascript
  Scenario: User changes notification email
    Then I should not be able to remove notifications from "sharetribe2@example.com"
    When I set notifications for email "sharetribe@example.com"
    Then I should be able to remove notifications from "sharetribe2@example.com"

  @javascript
  Scenario: User resends confirmation mail
    Then I should have unconfirmed email "sharetribe@yahoo.com"
    And I should not be able to resend confirmation for "sharetribe@example.com"
    And I should not be able to resend confirmation for "sharetribe2@example.com"
    And I should not be able to resend confirmation for "sharetribe@gmail.com"
    And I should be able to resend confirmation for "sharetribe@yahoo.com"
    When I resend confirmation for "sharetribe@yahoo.com"
    And "sharetribe@yahoo.com" should have 1 emails
    And I confirm email address "sharetribe@yahoo.com"
    Then I should have confirmed email "sharetribe@yahoo.com"
    And "sharetribe@yahoo.com" should have 1 emails