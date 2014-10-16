Feature: Admin edits a category

  Background: 
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has following transaction types enabled:
      | transaction_type  | en                | fi             |
      | Sell              | Selling           | Myydään        |
      | Give              | Giving away       | Annetaan       |
      | Lend              | Lending           | Lainataan      |
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Goodies           | Tavarat        |   
      | sub            | Tools             | Työkalut       |
      | sub            | Books             | Kirjat         |
      | main           | Services          | Palvelut       |
      | main           | Furniture         | Huonekalut     |
    And I am on the categories admin page

  @javascript
  Scenario: Admin changes category name
    When I change category "Furniture" name to "Tables"
    Then I should see that there is a top level category "Tables"

  @javascript
  Scenario: Admin tries to give category invalid name
    When I change category "Furniture" name to ""
    Then I should see 1 validation errors

  @javascript
  Scenario: Admin changes category parent
    When I change parent of category "Furniture" to "Goodies"
    Then I should see that there is a subcategory "Furniture"

  @javascript
  Scenario: Admin tries to give parent to category that has children
    When I try to edit category "Goodies"
    Then I should not see "Parent category"

  @javascript
  Scenario: Admin changes category transaction types
    When I change transaction types of category "Furniture" to following:
      | transaction_type  |
      | Selling           | 
      | Lending           | 
    Then category "Furniture" should have the following transaction types:
      | transaction_type  |
      | Selling           | 
      | Lending           | 
    When I change transaction types of category "Furniture" to following:
      | transaction_type  |
      | Lending           | 
    Then category "Furniture" should have the following transaction types:
      | transaction_type  |
      | Lending           | 

  @javascript
  Scenario: Admin tries to remove all transaction types
    When I try to remove all transaction types from category "Furniture"
    Then I should see 1 validation errors

  @javascript
  Scenario: Admin edits category order
    When I move category "Goodies" down 1 step
    Then the category order should be following:
      | category  |
      | Services  |
      | Goodies   |
      | Tools     |
      | Books     |
      | Furniture |
    When I move category "Books" up 1 step
    Then the category order should be following:
      | category  |
      | Services  |
      | Goodies   |
      | Books     |
      | Tools     |
      | Furniture |
    Then I should see "Successfully saved"
    When I refresh the page
    Then the category order should be following:
      | category  |
      | Services  |
      | Goodies   |
      | Books     |
      | Tools     |
      | Furniture |