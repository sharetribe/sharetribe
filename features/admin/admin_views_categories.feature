Feature: Admin views a category
  
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
    And I am on the categories admin page
    Then I should see "Items" as a top level category
    And I should see "Assembly" as a subcategory