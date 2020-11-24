Feature: Admin removes person custom fieldy

  Background:
    Given there is a person custom dropdown field "House type" in community "test" with options:
      | en             | fi                   |
      | No balcony     | Ei parveketta        |
      | French balcony | Ranskalainen parveke |
    And there is a person custom text field "Additional details" in community "test"
    And I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And I am on the person custom fields admin page
    Then I should see that there is a custom field "House type"
    And I should see that there is a custom field "Additional details"

  @javascript
  Scenario: Admin removes custom fields from category
    When I remove custom field "House type"
    And I remove custom field "Additional details"
    Then I should see that I do not have any custom fields
