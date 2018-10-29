@javascript
Feature: Admin edits stripe's byeer commision


  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    Given feature flag "buyer_commission" is enabled
    Given community "test" has country "US" and currency "USD"
    Given community "test" has payment method "stripe" provisioned
    Given community "test" has payment method "stripe" enabled by admin
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit stripe's settings
    When I go to the admin view of payment preferences of community "test"
    Then I should see "1. General settings"
    Then I should see "Stripe connected"
    And I focus on "#config_stripe_toggle"
    Then I should see "Transaction fee settings"
    And I fill in "payment_preferences_form_commission_from_seller" with "12"
    And I fill in "payment_preferences_form_minimum_transaction_fee" with "0.75"
    And I fill in "payment_preferences_form_commission_from_buyer" with "14"
    And I fill in "payment_preferences_form_minimum_buyer_transaction_fee" with "0.54"
    And I press "Save"
    Then I should see "Transaction fee settings updated"
    And I focus on "#config_stripe_toggle"
    And I should see "12" in the "payment_preferences_form_commission_from_seller" input
    And I should see "0.75" in the "payment_preferences_form_minimum_transaction_fee" input
    And I should see "14" in the "payment_preferences_form_commission_from_buyer" input
    And I should see "0.54" in the "payment_preferences_form_minimum_buyer_transaction_fee" input

  Scenario: Admin cannot edit buyer commision if paypal enabled
    Given community "test" has payment method "paypal" provisioned
    Given community "test" has payment method "paypal" enabled by admin
    When I go to the admin view of payment preferences of community "test"
    Then I should see "1. General settings"
    Then I should see "Stripe connected"
    And I focus on "#config_stripe_toggle"
    Then I should see "Transaction fee settings"
    And I should see disabled "payment_preferences_form_commission_from_buyer" input
    And I should see disabled "payment_preferences_form_minimum_buyer_transaction_fee" input

