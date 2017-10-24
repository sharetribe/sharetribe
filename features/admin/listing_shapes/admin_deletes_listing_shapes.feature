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

