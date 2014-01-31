Feature: Admin edits a custom field
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has custom fields enabled
    And there is a custom field "House type" in community "test"
    And there is a custom field "Balcony type" in community "test"
    And I am on the custom fields admin page
    Then I should see "House type" before "Balcony type"

  @javascript
  Scenario: Admin edits dropdown options
    When I move custom field "Balcony type" up
    And I refresh the page
    Then I should see "Balcony type" before "House type"