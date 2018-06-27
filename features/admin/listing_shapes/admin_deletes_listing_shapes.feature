@javascript
Feature: Admin create, update, destroy listing shapes
  As an admin
  I want to be able to edit the community listing shapes

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user delete order type Selling
    Given community "test" has order type "selling"
    When I go to the edit "selling" order type admin page
    Then I should see "Edit order type 'Selling'"
    When I confirm alert popup
    Given I will confirm all following confirmation dialogs in this page if I am running PhantomJS
    When I follow "Delete order type"
    Then I should see "Successfully deleted order type 'Selling'"

  @javascript
  Scenario: User successfully reopens a listing with a deleted listing shape
    Given there are following users:
      | person |
      | kassi_testperson1 |
     And "kassi_testperson1" has admin rights in community "test"
     And there is a listing with title "Hammer" from "kassi_testperson1" with category "Items" and with listing shape "Requesting"
     And I am logged in as "kassi_testperson1"
    When I go to the edit "requesting" order type admin page
    Then I should see "Edit order type 'Requesting'"
    When I confirm alert popup
     And I will confirm all following confirmation dialogs in this page if I am running PhantomJS
     And I follow "Delete order type"
    Then I should see "Successfully deleted order type 'Requesting'"
    Given I am on the profile page of "kassi_testperson1"
     And I follow "Show also closed"
     And I follow "Hammer"
    When I follow "Reopen listing"
     And I select subcategory "Tools"
    Then I should not see "Requesting"
    When I select "Selling" from listing type menu
     And I press "Post listing"
    Then I should see "Listing updated successfully"
     And I should see "Edit listing" within "#listing-message-links"
