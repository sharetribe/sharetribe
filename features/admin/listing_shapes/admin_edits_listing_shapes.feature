@javascript
Feature: Admin create, update, destroy listing shapes
  As an admin
  I want to be able to edit the community listing shapes

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user edit order type Selling
    Given community "test" has order type "selling"
    When I go to the edit "selling" order type admin page
    Then I should see "Edit order type 'Selling'"
    When I fill in "Sally" for "name_en"
    When I fill in "Liekko" for "name_fi"
    When I fill in "Ruth" for "action_button_label_en"
    When I fill in "Raiju" for "action_button_label_fi"
    When I press "Save"
    Then I should see "Changes to order type 'Sally' saved"

