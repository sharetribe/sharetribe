Feature: Admin add a listing fields

  Background:
    Given I am logged in as "kassi_testperson2"
    And "kassi_testperson2" has admin rights in community "test"
    And I am on the user fields admin2 page

  @javascript
  Scenario: Admin adds Dropdown custom field
    When I follow "+ Add a user field"
    And I select "Dropdown" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "House type"
    And I fill in "custom_field[name_attributes][fi]" with "Talon tyyppi"
    Then I follow "+ Add an option"
    And I fill in "selector_label[en]" with "Room"
    And I fill in "selector_label[fi]" with "Huone"
    And I press "Save option"
    Then I follow "+ Add option"
    And I fill in "selector_label[en]" with "Appartment"
    And I fill in "selector_label[fi]" with "Asunto"
    And I press "Save option"
    And I press submit
    Then I should see "House type" within ".custom-field-title"

  @javascript
  Scenario: Admin adds Dropdown custom field without options
    When I follow "+ Add a user field"
    And I select "Dropdown" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "House type"
    And I fill in "custom_field[name_attributes][fi]" with "Talon tyyppi"
    And I press submit
    Then I should see 1 validation errors in admin2

  @javascript
  Scenario: Admin adds numeric field
    When I follow "+ Add a user field"
    And I select "Number" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "Area"
    And I fill in "custom_field[name_attributes][fi]" with "Talon Area"
    Then I set numeric field min value to 0
    And I set numeric field max value to 100
    And I press submit
    Then I should see "Area" within ".custom-field-title"

  @javascript
  Scenario: Admin adds Checkbox custom field
    When I follow "+ Add a user field"
    And I select "Checkbox" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "Checkbox type"
    And I fill in "custom_field[name_attributes][fi]" with "Talon tyyppi"
    Then I follow "+ Add option"
    And I fill in "selector_label[en]" with "Room"
    And I fill in "selector_label[fi]" with "Huone"
    And I press "Save option"
    Then I follow "+ Add an option"
    And I fill in "selector_label[en]" with "Appartment"
    And I fill in "selector_label[fi]" with "Asunto"
    And I press "Save option"
    And I press submit
    Then I should see "Checkbox type" within ".custom-field-title"

  @javascript
  Scenario: Admin adds Date custom field
    When I follow "+ Add a user field"
    And I select "Date" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "Area Date"
    And I fill in "custom_field[name_attributes][fi]" with "Talon Area"
    And I press submit
    Then I should see "Area Date" within ".custom-field-title"
