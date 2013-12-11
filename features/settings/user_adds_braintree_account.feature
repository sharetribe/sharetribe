Feature: User adds Braintree account
  In order to receive payments
  As a seller
  I want to be able to fill in my payout details
  
  Background:
    Given there are following users:
      | person                | id |
      | bt_test_person        | 123abcdef |
    Given community "test" has payments in use via BraintreePaymentGateway
    And I am logged in as "bt_test_person"
    And I am on the account settings page
    Then I should see "Payments"

  @javascript
  Scenario: User can browse to Braintree account settings
    When I browse to payment settings
    Then I should be on the new Braintree account page

  @javascript
  Scenario: User creates Braintree accout
    Given I am on the new Braintree account page
    And Braintree merchant creation is mocked
    When I fill in Braintree account details
    And I press submit
    Then I should see "Account status: pending"
    When Braintree webhook "sub_merchant_account_approved" with id "123abcdef" is triggered
    And I refresh the page
    Then I should see "Account status: active"

  @javascript
  Scenario: User enters invalid information catched by front-end validations
    Given I am on the new Braintree account page
    When I fill in Braintree account details
    And I fill in "braintree_account[routing_number]" with "1010"
    And I press submit
    Then I should see validation error


  @javascript
  Scenario: User gets flash error if transaction was unsuccessful
    Given I am on the new Braintree account page
    And Braintree merchant creation is mocked to return failure
    When I fill in Braintree account details
    And I press submit
    Then I should see flash error