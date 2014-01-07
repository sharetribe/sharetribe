Feature: Admin adds custom field for category
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And I am on the custom fields admin page
    Then I should see that I do not have any custom fields

  @javascript
  Scenario: Admin removes custom field from category
    When I add a new custom field "House type" for category "housing_checkbox" with options "Condo" and "Appartment"
    Then I should see that there is a custom field "House type"