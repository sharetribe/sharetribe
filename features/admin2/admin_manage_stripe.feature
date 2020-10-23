@javascript
Feature: Admin manage stripe

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    Given feature flag "buyer_commission" is enabled
    Given community "test" has country "US" and currency "USD"
    Given community "test" has payment method "stripe" provisioned
    Given community "test" has payment method "stripe" enabled by admin
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can enable or disable payment method
    When I go to the admin2 view of stripe payment of community "test"
    Then I should see "Stripe enabled"
    When I follow "Disable Stripe"
    Then I press "Disable Stripe" within ".modal-footer"
    Then I should see "Stripe disabled"
    When I follow "Enable Stripe"
    Then I should see "Stripe enabled"

  Scenario: Admin user can edit stripe's settings
    When I go to the admin2 view of stripe payment of community "test"
    Then I should see "Stripe enabled"
    Then I should see "Stripe commission settings"
    And I fill in "payment_preferences_form_commission_from_seller" with "12"
    And I fill in "payment_preferences_form_minimum_transaction_fee" with "0.75"
    And I fill in "payment_preferences_form_commission_from_buyer" with "14"
    And I fill in "payment_preferences_form_minimum_buyer_transaction_fee" with "0.54"
    And I press "Save changes"
    Then I should see "Transaction fee settings updated"
    And I should see "12" in the "payment_preferences_form_commission_from_seller" input
    And I should see "0.75" in the "payment_preferences_form_minimum_transaction_fee" input
    And I should see "14" in the "payment_preferences_form_commission_from_buyer" input
    And I should see "0.54" in the "payment_preferences_form_minimum_buyer_transaction_fee" input
