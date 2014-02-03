Feature: Admin removes a category

  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Items             | Tavarat        |   
      | sub            | Tools             | Työkalut       |
      | sub            | Books             | Kirjat         |
      | main           | Services          | Palvelut       |
    And there is item offer with title "Sound of Music" and with category "Books"

  @javascript
  Scenario: Admin removes a subcategory
    Given I am on the categories admin page
    When I remove subcategory "Tools"
    Then the category "Tools" should be removed

  @javascript
  Scenario: Admin removes a top level category
    Given I am on the categories admin page
    When I remove category "Items"
    Then I should see warning about the removal of subcategory "Tools"
    When I confirm category removal
    Then the category "Items" should be removed

  @javascript
  Scenario: Admin is not able to remove last top level categories
    Given "Services" is the only top level category
    And I am on the categories admin page
    Then I should not be able to remove category "Services"

  @javascript
  Scenario: Admin removes a subcategory with listings
    Given I am on the categories admin page
    When I remove category "Books"
    Then I should be able to select new category for listing "Sound of Music"
    When I select "Items" as a new category
    And I confirm category removal
    Then the category "Books" should be removed
    And the listing "Sound of Music" should belong to category "Items"