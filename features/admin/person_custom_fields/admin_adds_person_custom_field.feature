Feature: Admin adds a person custom field

  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And I am on the person custom fields admin page
    Then I should see that I do not have any custom fields

  @javascript
  Scenario: Admin adds custom field
    When I add a new person custom field "House type"
    Then I should see that there is a custom field "House type"

  @javascript
  Scenario: Admin adds custom field with invalid data
    When I add a new person custom field "House type" with invalid data
    Then I should see 2 validation errors

  @javascript
  Scenario: Admin adds numeric field
    When I add a new person numeric field "Area" with min value 0 and max value 100
    Then I should see that there is a custom field "Area"

  @javascript
  Scenario: Admin adds numeric field with invalid data
    When I add a new person numeric field "Area" with min value 100 and max value 99
    Then I should see 2 validation errors

  @javascript
  Scenario: Admin adds checkbox field
    When I add a new person checkbox field Amenities
    Then I should see that there is a custom field "Amenities"

  @javascript
  Scenario: Admin adds checkbox field with invalid data
    When I add a new person checkbox field Amenities with invalid data
    Then I should see 1 validation errors

  @javascript
  Scenario: Admin adds date field
    When I add a new person date field "Begin date"
    Then I should see that there is a custom field "Begin date"
