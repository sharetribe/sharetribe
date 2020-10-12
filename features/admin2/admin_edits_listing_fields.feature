Feature: Admin edits listing fields
  
  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And community "test" has following category structure:
      | category_type  | en                | fi             |
      | main           | Items             | Tavarat        |
      | main           | Housing spaces    | Tilat          |
    And there is a custom field "House type" in community "test" for category "Housing spaces"
    And there is a custom dropdown field "Balcony type" in community "test" with options:
      | en             | fi                   |
      | No balcony     | Ei parveketta        |
      | French balcony | Ranskalainen parveke |
      | Backyard       | Takapiha             |
    And I am on the listing fields admin2 page
    Then I should see "House type"
    And I should see "Balcony type"

  @javascript
  Scenario: Admin changes custom field name
    When I change custom field "House type" name to "Room type"
    Then I should see "Room type"
  
  @javascript
  Scenario: Admin tries to give custom field invalid name
    When I change custom field "House type" name to ""
    Then I should see 1 validation errors in admin2

  @javascript
  Scenario: Admin changes categories
    When I change custom field "House type" categories
    Then correct categories should be stored

  @javascript
  Scenario: Admin tries to remove all categories
    When I try to remove all categories
    Then I should see 1 validation errors in admin2

  @javascript
  Scenario: Admin removes custom fields from category
    When I remove listing field "House type"
    And I remove listing field "Balcony type"
    Then I should see that I do not have any listing fields

