Feature: Admin removes custom field from category
  
  Background:
    Given there is a dropdown field "House type" for category "housing" with options:
      | title |
      | condo |
      | house |
    And I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has custom fields enabled
    And I am on the custom fields admin page
    Then I should see that there is a custom field "House type"

  @javascript
  Scenario: Admin removes custom field from category
    When I remove custom field "House type"
    Then I should see that I do not have any custom fields
