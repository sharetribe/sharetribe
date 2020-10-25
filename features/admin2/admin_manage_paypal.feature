@javascript
Feature: Admin manage stripe

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    Given feature flag "buyer_commission" is enabled
    Given community "test" has country "US" and currency "USD"
    Given community "test" has payment method "paypal" provisioned
    Given community "test" has payment method "paypal" enabled by admin
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can enable or disable payment method
    When I go to the admin2 view of paypal payment of community "test"
    Then I should see "Your PayPal account mildred@example.com has been connected with Sharetribe"
    When I follow "Disable PayPal"
    Then I press "Disable PayPal" within ".modal-footer"
    Then I should see "Your PayPal account mildred@example.com has been disconnected from Sharetribe"
    When I follow "Enable PayPal"
    Then I should see "Your PayPal account mildred@example.com has been connected with Sharetribe"

  Scenario: Admin user can edit stripe's settings
    When I go to the admin2 view of paypal payment of community "test"
    Then I should see "Your PayPal account mildred@example.com has been connected with Sharetribe"
    Then I should see "PayPal commission settings"
    And I fill in "payment_preferences_form_commission_from_seller" with "12"
    And I fill in "payment_preferences_form_minimum_transaction_fee" with "0.75"
    And I press "Save changes"
    Then I should see "Transaction fee settings updated"
    And I should see "12" in the "payment_preferences_form_commission_from_seller" input
    And I should see "0.75" in the "payment_preferences_form_minimum_transaction_fee" input
