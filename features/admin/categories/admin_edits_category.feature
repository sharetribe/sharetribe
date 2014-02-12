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
      | main           | Items             | Tavarat        |   
      | sub            | Tools             | Työkalut       |
      | sub            | Books             | Kirjat         |
      | main           | Services          | Palvelut       |

  @javascript
  Scenario: Admin changes category name
    When I change category "Items" name to "Goodies"
    Then I should see that there is a top level category "Items"

  @javascript
  Scenario: Admin tries to give category invalid name
    When I change category "Items" name to ""
    Then I should see 1 validation errors

  @javascript
  Scenario: Admin changes category parent
    When I change parent of category "Services" to "Items"
    Then I should see that there is a subcategory "Services" under "Items"

  @javascript
  Scenario: Admin tries to give parent to category that has children
    When I change category "Items" name to ""
    Then I should see 1 validation errors

  @javascript
  Scenario: Admin changes category transaction types
    When I change transaction types of category "Items" to following:
      | transaction_type  |
      | Give              | 
      | Lend              | 
    Then category "Items" should have the following transaction types:
      | transaction_type  |
      | Give              | 
      | Lend              | 

  @javascript
  Scenario: Admin tries to remove all transaction types
    When I unselect all transaction types from category "Items"
    Then I should see 1 validation errors

  @javascript
  Scenario: Admin edits category order
    Given I am on the categories admin page
    When I move category "Items" down 1 step
    Then the category order should be following:
      | category |
      | Services |
      | Items    |
      | Tools    |
      | Books    |
    When I move category "Books" up 1 step
    Then the category order should be following:
      | category |
      | Services |
      | Items    |
      | Books    |
      | Tools    |
    Then I should see "Successfully saved"
    When I refresh the page
    Then the category order should be following:
      | category |
      | Services |
      | Items    |
      | Books    |
      | Tools    |