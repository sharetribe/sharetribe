Feature: User changes email address
  In order to change the email address associated with me in Sharetribe
  As a user
  I want to be able to change my email address

  Background:
    Given there are following users:
      | person      |
      | sharetribe1 |
    And there are following emails:
      | person      | address                 | send_notifications |
      | sharetribe1 | sharetribe@example.com  | false              |
      | sharetribe1 | sharetribe2@example.com | true               |
      | sharetribe1 | sharetribe@gmail.com    | false              |
    And there are following communities:
      | community               | allowed_emails |
      | test_community          | @example.com   |
      | another_test_community  | @gmail.com     |
    And "sharetribe1" is a member of community "test_community"
    And "sharetribe1" is a member of community "another_test_community"
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
    Then I should not be able to remove email "sharetribe2@example.com"
    Then I should not be able to remove email "sharetribe@gmail.com"
    When I remove email "sharetribe@example.com"
    Then I should not have email "sharetribe@example.com"

  @javascript
  Scenario: User changes notification email
    Then I should not be able to remove notifications from "sharetribe2@example.com"
    When I set notifications for email "sharetribe@example.com"
    Then I should be able to remove notifications from "sharetribe2@example.com"
