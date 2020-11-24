Feature: Admin adds a custom field part 2

# These tests are quite slow. Spread them out between this file and
# the corresponding Part 1, so that CI can balance runtime in parallel
# well.

  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Items             | Tavarat        |
      | main           | Spaces            | Tilat          |
    And I am on the custom fields admin page
    Then I should see that I do not have any custom fields

  @javascript
  Scenario: Admin adds checkbox field
    When I add a new checkbox field Amenities
    Then I should see that there is a custom field "Amenities"

  @javascript
  Scenario: Admin adds checkbox field with invalid data
    When I add a new checkbox field Amenities with invalid data
    Then I should see 2 validation errors

  @javascript
  Scenario: Admin adds date field
    When I add a new date field "Begin date"
    Then I should see that there is a custom field "Begin date"