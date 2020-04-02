Feature: Admin adds a person custom field

# These tests are quite slow. Spread them out between this file and
# the corresponding Part 2, so that CI can balance runtime in parallel
# well.

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
