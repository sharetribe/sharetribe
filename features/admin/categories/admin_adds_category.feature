Feature: Admin adds a category

  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And I am on the categories admin page

  @javascript
  Scenario: Admin adds a top level category
    When I add a new category "Buildings"
    Then I should see that there is a top level category "Buildings"

  @javascript
  Scenario: Admin adds a subcategory
    When I add a new category "Shacks" under category "Buildings"
    Then I should see that there is a subcategory "Shacks"

  @javascript
  Scenario: Admin adds category with invalid data
    When I add a new category "Buildings" with invalid data
    Then I should see 2 validation errors