Feature: Admin edits listing fields
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And there is a custom user dropdown field "Balcony type" in community "test" with options:
      | en             | fi                   |
      | No balcony     | Ei parveketta        |
      | French balcony | Ranskalainen parveke |
      | Backyard       | Takapiha             |
    And I am on the user fields admin2 page
    Then I should see "Balcony type"

  @javascript
  Scenario: Admin changes custom field name
    When I change custom field "Balcony type" name to "Room type"
    Then I should see "Room type"
  
  @javascript
  Scenario: Admin tries to give custom field invalid name
    When I change custom field "Balcony type" name to ""
    Then I should see 1 validation errors in admin2

  @javascript
  Scenario: Admin removes custom fields from category
    When I remove user field "Balcony type"
    Then I should see that I do not have any listing fields

