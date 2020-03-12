@javascript
Feature: Admin edits general admin notifications page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit privacy settings
    When I go to the admin2 general admin notifications community "test"
    And I check "Send admins an email whenever a new user signs up"
    And I check "Send admins an email whenever a new transaction starts"
    And I press submit
    When I go to the admin2 general admin notifications community "test"
    Then the "Send admins an email whenever a new user signs up" checkbox should be checked
    And the "Send admins an email whenever a new transaction starts" checkbox should be checked
