Feature: Admin adds a category

  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Items             | Tavarat        |
    And I am on the categories admin page

  @javascript
  Scenario: Admin adds a top level category
    When I add a new category "Spaces"
    Then I should see that there is a top level category "Spaces"