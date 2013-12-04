Feature: User pays accepted request

  Background:
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there are following Braintree accounts:
      | person            | status |
      | kassi_testperson1 | active |
    And community "test" has payments in use via BraintreePaymentGateway
    And there is item offer with title "math book" from "kassi_testperson1" and with share type "sell" and with price "12"
    And there is an accepted request for "math book" with price "5555" from "kassi_testperson2"

  Scenario:
    Given I am logged in as "kassi_testperson2"
    And I want to pay "math book"
    Then I should be able to fill in my payment details for Braintree
    And I should be able to see that the payment was successful
