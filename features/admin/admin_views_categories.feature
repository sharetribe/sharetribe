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
    And I am on the categories admin page
    And wait for 10 seconds
    Then I should see "Items" within "#top-level-category-items"
    And I should see "Assembly" within "#subcategory-assembly"