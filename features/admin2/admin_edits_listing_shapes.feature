@javascript
Feature: Admin create, update, destroy listing shapes
  As an admin
  I want to be able to edit the community listing shapes

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user edit order type Selling
    When I go to the order types admin2 page of community "test"
    Then I should see "Selling"
    Then I click ".shape_selling"
    When I fill in "Sally" for "name_en"
    When I fill in "Liekko" for "name_fi"
    When I fill in "Ruth" for "action_button_label_en"
    When I fill in "Raiju" for "action_button_label_fi"
    When I press "Save changes"
    Then I should see "Changes to order type 'Sally' saved"

  Scenario: Admin user create new order type Selling
    When I go to the order types admin2 page of community "test"
    Then I should see "Order types determine how the order process works on your marketplace."
    When I follow "+ Add a new order type"
    Then I select "Selling products" from "template_order_type"
    Then I should see "Checkout button label"
    When I fill in "Selling something nice" for "name_en"
    Then I follow "+ Add a custom pricing unit"
    When I fill in "Customize something nice" for "unit_label_en"
    When I fill in "Customize something nice" for "unit_label_fi"
    When I fill in "Customize it!" for "selector_label_en"
    When I fill in "Customize it!" for "selector_label_fi"
    Then I press "Save pricing unit"
    Then I should see "Per Customize something nice"
    When I press "Add the new order type"
    Then I should see "Selling something nice"

  Scenario: Admin user create new order type Renting products
    When I go to the order types admin2 page of community "test"
    Then I should see "Order types determine how the order process works on your marketplace."
    When I follow "+ Add a new order type"
    Then I select "Renting products" from "template_order_type"
    Then I should see "heckout button label"
    When I fill in "Renting something nice" for "name_en"
    When I press "Add the new order type"
    Then I should see "Renting something nice"

  Scenario: Admin user delete order type Selling
    When I go to the order types admin2 page of community "test"
    Then I should see "Selling"
    Then I click ".delete_shape_selling"
    Then I press "Delete the order type"
    Then I should see "Successfully deleted order type 'Selling'"
