Feature: Admin adds a category

  Background:
    Given I am logged in as "kassi_testperson1"
    And I am on the categories admin page

  @javascript
  Scenario: Admin adds a top level category and a subcategory
    Given this test is pending. This should be fixed when transactional cleaning strategy is in use.
    When I add a new category "Buildings"
    Then I should see that there is a top level category "Buildings"
    When I add a new category "Shacks" under category "Buildings"
    Then I should see that there is a subcategory "Shacks"

  @javascript
  Scenario: Admin adds category with invalid data
    When I add a new category "Buildings" with invalid data
    Then I should see 2 validation errors
