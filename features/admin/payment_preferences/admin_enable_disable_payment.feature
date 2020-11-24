@javascript
Feature: Admin enable or disable payment methods (gateways)
  In order to have custom detail texts tailored specifically for my community
  As an admin
  I want to be able to edit the community payment methods

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    Given community "test" has country "US" and currency "USD"
    Given community "test" has payment method "paypal" provisioned
    Given community "test" has payment method "paypal" enabled by admin
    Given community "test" has payment method "stripe" provisioned
    Given community "test" has payment method "stripe" enabled by admin
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can enable or disable payment method
    When I go to the admin view of payment preferences of community "test"
    Then I should see "1. General settings"
    Then I should see "Stripe connected"
    When I confirm alert popup
    Given I will confirm all following confirmation dialogs in this page if I am running PhantomJS
    When I follow "Disable Stripe"
    Then I should see "Stripe disabled"
    When I follow "Enable Stripe again"
    Then I should see "Stripe connected"
    Then I should see "PayPal connected"
    When I confirm alert popup
    Given I will confirm all following confirmation dialogs in this page if I am running PhantomJS
    When I follow "Disable PayPal"
    Then I should see "PayPal disabled"
    When I follow "Enable PayPal again"
    Then I should see "PayPal connected"


