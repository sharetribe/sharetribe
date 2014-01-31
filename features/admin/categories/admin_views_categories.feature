Feature: Admin views categories
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Items             | Tavarat        |   
      | sub            | Tools             | Työkalut       |
      | sub            | Books             | Kirjat         |
      | main           | Services          | Palvelut       |   
      | sub            | Assembly          | Kokoaminen     |
      | sub            | Delivery          | Toimitus       | 
      | sub            | Cleaning          | Siivous        |  
    
  @javascript  
  Scenario: Admin views category list
    When I go to the categories admin page
    Then I should see that there is a top level category "Items"
    And I should see that there is a subcategory "Assembly"