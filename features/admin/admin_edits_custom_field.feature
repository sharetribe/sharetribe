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
  Scenario: Admin tries to edit custom field with invalid data
    When I try to edit custom field "House type" with invalid data
    Then I should see 1 validation errors