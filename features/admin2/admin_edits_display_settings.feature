@javascript
Feature: Admin edits design display page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And I am logged in as "kassi_testperson1"
    And I go to the admin2 design display community "test"

  Scenario: Admin can change the default listing view to list
    Given community "test" has default browse view "grid"
    When I choose "List"
    And I press submit
    Then I go to the homepage
    And I should see the browse view selected as "List"

  Scenario: Admin can change the name display type to full name (First Last)
    Given community "test" has name display type "first_name_with_initial"
    When I choose "community_name_display_type_full_name"
    And I press submit
    Then I go to the homepage
    And I should see my name displayed as "Kassi Testperson1"

  Scenario: Admin can change to show the listing type
    Given community "test" has default browse view "list"
    When I choose "List"
    And I check "Show listing's type on the List view"
    And I press submit
    Then I go to the homepage
    And I should see the browse view selected as "List"
    And I should see "Requesting"

  Scenario: Admin can change to hide the listing type
    Given community "test" has default browse view "list"
    When I choose "List"
    And I uncheck "Show listing's type on the List view"
    And I press submit
    Then I go to the homepage
    And I should see the browse view selected as "List"
    And I should not see "Requesting"

  Scenario: Admin can show listing publish date
    When I check "Show listing's publishing date on the listing page"
    And I press submit
    Then I go to the listing page
    And I should see "Listing created"

  Scenario: Admin can show listing publish date
    When I uncheck "Show listing's publishing date on the listing page"
    And I press submit
    Then I go to the listing page
    And I should not see "Listing created"
