@javascript
Feature: Admin create, update, destroy listing shapes
  As an admin
  I want to be able to edit the community listing shapes

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user create new order type Selling
    When I go to the order types admin page of community "test"
    Then I should see "Order types determine how the order process works in your site."
    When I select "Selling products" from "template"
    Then I should see "Create order type"
    When I fill in "Selling something nice" for "name_en"
    When I press "Create"
    Then I should see "Selling something nice"

  Scenario: Admin user create new order type Renting products
    When I go to the order types admin page of community "test"
    Then I should see "Order types determine how the order process works in your site."
    When I select "Renting products" from "template"
    Then I should see "Create order type"
    When I fill in "Renting something nice" for "name_en"
    When I press "Create"
    Then I should see "Renting something nice"

  Scenario: Admin user create new order type Offering services
    When I go to the order types admin page of community "test"
    Then I should see "Order types determine how the order process works in your site."
    When I select "Offering services" from "template"
    Then I should see "Create order type"
    When I fill in "Offering something nice" for "name_en"
    When I press "Create"
    Then I should see "Offering something nice"

  Scenario: Admin user create new order type Giving things away
    When I go to the order types admin page of community "test"
    Then I should see "Order types determine how the order process works in your site."
    When I select "Offering services" from "template"
    Then I should see "Create order type"
    When I fill in "Giving away something nice" for "name_en"
    When I press "Create"
    Then I should see "Giving away something nice"

  Scenario: Admin user create new order type Requesting
    When I go to the order types admin page of community "test"
    Then I should see "Order types determine how the order process works in your site."
    When I select "Offering services" from "template"
    Then I should see "Create order type"
    When I fill in "Requesting something nice" for "name_en"
    When I press "Create"
    Then I should see "Requesting something nice"

  Scenario: Admin user create new order type Posting announcements
    When I go to the order types admin page of community "test"
    Then I should see "Order types determine how the order process works in your site."
    When I select "Offering services" from "template"
    Then I should see "Create order type"
    When I fill in "Announce something nice" for "name_en"
    When I press "Create"
    Then I should see "Announce something nice"

  Scenario: Admin user create new order type Custom
    When I go to the order types admin page of community "test"
    Then I should see "Order types determine how the order process works in your site."
    When I select "Custom" from "template"
    Then I should see "Create order type"
    When I fill in "Customize something nice" for "name_en"
    When I fill in "Customize something nice" for "name_fi"
    When I fill in "Customize it!" for "action_button_label_en"
    When I fill in "Customize it!" for "action_button_label_fi"
    When I press "Create"
    Then I should see "Customize something nice"

