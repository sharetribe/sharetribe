Feature: Admin edits a custom field
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has custom fields enabled
    And there is a custom field "House type" in community "test"
    And I am on the custom fields admin page
    Then I should see "House type"

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