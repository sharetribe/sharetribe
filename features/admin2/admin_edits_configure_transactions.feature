@javascript
Feature: Admin edits configure transactions page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit send automatic newsletters to all users
    When I go to the admin2 automatic newsletter community "test"
    And I check "community_automatic_newsletters"
    Then I press submit
    And the "community_automatic_newsletters" checkbox should be checked

  Scenario: Admin user can edit default automatic newsletter frequency
    When I go to the admin2 automatic newsletter community "test"
    And I select "Daily" from "community_default_min_days_between_community_updates"
    Then I press submit
    And I should see selected "Daily" in the "community_default_min_days_between_community_updates" dropdown
