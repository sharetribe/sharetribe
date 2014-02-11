Feature: Admin adds a category

  Background:
    Given there are following communities:
      | community      |
      | test_community |
    And community "test_community" has following transaction types enabled:
      | transaction_type  | en                | fi             |
      | Sell              | Selling           | Myydään        |
      | Lend              | Lending           | Annetaan       |
    And community "test_community" has following category structure:
      | category_type  | en                | fi             |
      | main           | Items             | Tavarat        |
    And there are following users:
      | person      |
      | test_person |
    And user "test_person" is member of community "test_community"
    And "test_person" has admin rights in community "test_community"
    And I move to community "test_community"
    And I am logged in as "test_person"
    And I am on the categories admin page

  @javascript
  Scenario: Admin adds a top level category and a subcategory
    When I add a new category "Buildings"
    Then I should see that there is a top level category "Buildings"
    When I add a new category "Shacks" under category "Buildings"
    Then I should see that there is a subcategory "Shacks"

  @javascript
  Scenario: Admin adds category with invalid data
    When I add a new category "Buildings" with invalid data
    Then I should see 1 validation errors