Feature: Admin adds a custom field

# These tests are quite slow. Spread them out between this file and
# the corresponding Part 2, so that CI can balance runtime in parallel
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
  Scenario: Admin adds custom field
    When I add a new custom field "House type"
    Then I should see that there is a custom field "House type"

  @javascript
  Scenario: Admin adds custom field with invalid data
    When I add a new custom field "House type" with invalid data
    Then I should see 3 validation errors

  @javascript
  Scenario: Admin adds numeric field
    When I add a new numeric field "Area" with min value 0 and max value 100
    Then I should see that there is a custom field "Area"

  @javascript
  Scenario: Admin adds numeric field with invalid data
    When I add a new numeric field "Area" with min value 100 and max value 99
    Then I should see 2 validation errors