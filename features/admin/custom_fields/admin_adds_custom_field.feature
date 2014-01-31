Feature: Admin adds a custom field
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has custom fields enabled
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