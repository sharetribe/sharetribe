Feature: Admin edits a custom field
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Items             | Tavarat        |
      | main           | Housing spaces    | Tilat          |
    And there is a custom field "House type" in community "test" for category "Housing spaces"
    And there is a custom dropdown field "Balcony type" in community "test" with options:
      | en             | fi                   |
      | No balcony     | Ei parveketta        |
      | French balcony | Ranskalainen parveke |
      | Backyard       | Takapiha             |
    And I am on the custom fields admin page
    Then I should see "House type"
    And I should see "Balcony type"
    Then the option order for "Balcony type" should be following:
      | option         |
      | No balcony     |
      | French balcony |
      | Backyard       |

  @javascript
  Scenario: Admin changes custom field name
    When I change custom field "House type" name to "Room type"  
    Then I should see "Room type"
  
  @javascript
  Scenario: Admin tries to give custom field invalid name
    When I change custom field "House type" name to "" 
    Then I should see 1 validation errors

  @javascript
  Scenario: Admin changes categories
    When I change custom field "House type" categories 
    Then correct categories should be stored

  @javascript
  Scenario: Admin tries to remove all categories
    When I try to remove all categories
    Then I should see 1 validation errors
    
  @javascript
  Scenario: Admin edits dropdown options
    When I edit dropdown "House type" options
    Then options should be stored correctly

  @javascript
  Scenario: Admin edits dropdown option order
    When I move option "No balcony" for "Balcony type" down 1 step
    Then the option order for "Balcony type" should be following:
      | option         |
      | French balcony |
      | No balcony     |
      | Backyard       |
    When I move option "Backyard" for "Balcony type" up 2 steps
    Then the option order for "Balcony type" should be following:
      | option         |
      | Backyard       |
      | French balcony |
      | No balcony     |