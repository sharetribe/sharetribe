Feature: Admin edits community look-and-feel
  In order to give my marketplace distinct look
  As an admin
  I want to be able to modify look-and-feel

  Background:
     Given there are following users:
      | person            | given_name | family_name | email               | membership_created_at     |
      | manager           | matti      | manager     | manager@example.com | 2014-03-01 00:12:35 +0200 |
      | kassi_testperson1 | john       | doe         | test2@example.com   | 2013-03-01 00:12:35 +0200 |
      | kassi_testperson2 | jane       | doe         | test1@example.com   | 2012-03-01 00:00:00 +0200 |
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And "kassi_testperson1" has admin rights in community "test"
    And I am on the edit look-and-feel page

  @javascript
  Scenario: Admin can choose the default listing view to list
    Given community "test" has default browse view "grid"
    And I change the default browse view to "list"
    And I navigate to the homepage
    Then I should see the browse view selected as "list"

  @javascript
  Scenario: Admin can choose the default listing view to list
    Given community "test" has default browse view "grid"
    And I change the default browse view to "map"
    And I navigate to the homepage
    Then I should see the browse view selected as "map"

