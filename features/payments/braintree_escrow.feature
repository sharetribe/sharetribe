Feature: User cancels escrow payment
  Background:
    Given there are following users:
      | person            | email                  |
      | kassi_testperson1 | kassi1@sharetribe.com  |
      | kassi_testperson2 | kassi2@sharetribe.com  |
      | manager           | manager@sharetribe.com |
    And there are following Braintree accounts:
      | person            | status | community |
      | kassi_testperson1 | active | test      |
    And community "test" has payments in use via BraintreePaymentGateway
    And "kassi_testperson1" does not have admin rights in community "test"
    And "manager" has admin rights in community "test"
    And there is a listing with title "math book" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And the price of that listing is 101.00 USD
    And there is a pending request "math book" from "kassi_testperson2" about that listing
    And the request is accepted
    And "kassi_testperson2" has paid for that listing

  @javascript
  Scenario: User cancels escrow payment
    Given I am logged in as "kassi_testperson2"
    When I cancel the transaction
    And I skip feedback
    And the system processes jobs
    Then "kassi1@sharetribe.com" should receive an email with subject "Payment canceled"
    Then "manager@sharetribe.com" should receive an email with subject "Payment canceled"