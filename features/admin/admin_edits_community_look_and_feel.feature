@javascript
Feature: Admin edits community look-and-feel
  In order to give diversify my marketplace from my competitors
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

  Scenario: Admin can change the default listing view to list
    Given community "test" has default browse view "grid"
    When I change the default browse view to "List"
    And I go to the homepage
    Then I should see the browse view selected as "List"

  Scenario: Admin can change the name display type to full name (First Last)
    Given community "test" has name display type "first_name_with_initial"
    When I change the name display type to "Full name (First Last)"
    And I refresh the page
    Then I should see my name displayed as "matti manager"

  Scenario: Admin changes new listing button color
    Then I should see that the background color of Post a new listing button is "2AB865"
    And I set the new listing button color to "FF0099"
    And I press submit
    Then I should see that the background color of Post a new listing button is "FF0099"