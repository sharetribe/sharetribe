@javascript
Feature: Admin changes a person custom fields order
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And there is a person custom field "House type" in community "test"
    And there is a person custom field "Balcony type" in community "test"
    And I am on the person custom fields admin page
    Then I should see "House type" before "Balcony type"

  Scenario: Admin edits dropdown options
    When I move custom field "Balcony type" up
    And I refresh the page
    Then I should see "Balcony type" before "House type"
