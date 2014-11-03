Feature: Seller creates an invoice with Braintree
  In order to get money from buyer
  As a seller
  I want to invoice the buyer with Braintree payments

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And community "test" has payments in use via BraintreePaymentGateway with seller commission 10
    And there is a listing with title "Power drill" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And the price of that listing is 20.90 USD
    And there is a pending request "I request this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    Then I should see that there is 1 new message
    And I should see "Waiting for you to accept the request"

  @javascript
  Scenario: User can not accept request without Braintree account
    When I follow "I request this"
    And I follow "Accept request"
    Then I should see "You need to fill in payout details before you can accept the request"

  @javascript
  Scenario: User can not accept request without active Braintree account
    Given there are following Braintree accounts:
      | person            | status  | community |
      | kassi_testperson1 | pending | test      |
    When I follow "I request this"
    And I follow "Accept request"
    Then I should see "You need to fill in payout details before you can accept the request"

  @javascript
  Scenario: User accepts a payment-requiring request and creates an invoice
    Given there are following Braintree accounts:
      | person            | status | community |
      | kassi_testperson1 | active | test      |
    When I follow "I request this"
    And I follow "Accept request"
    Then I should see "20.90" in the "listing_conversation_payment_attributes_sum" input
    And I should see "2.09" within "#service-fee"
    And I should see "18.81" within "#payment-to-seller"
    When I fill in "listing_conversation_payment_attributes_sum" with "dsdfs"
    And I press "Send"
    Then I should see "You need to insert a valid monetary value."
    When I fill in "listing_conversation_payment_attributes_sum" with "0,9"
    And I press "Send"
    Then I should see "The price cannot be lower than"
    When I fill in "listing_conversation_payment_attributes_sum" with ""
    And I press "Send"
    Then I should see "You need to insert a valid monetary value."
    When I send keys "178,30" to form field "listing_conversation_payment_attributes_sum"
    Then I should see "17.83" within "#service-fee"
    And I should see "160.47" within "#payment-to-seller"
    And I press "Send"
    Then I should see "Accepted"
    And I should see "to pay" within ".conversation-status"
    When the system processes jobs
    Then "kassi_testperson2@example.com" should have 1 email
    When I open the email with subject "Your request was accepted"
    Then I should see "has accepted your request" in the email body
    When "4" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 2 emails
    When I open the email with subject "Remember to pay"
    Then I should see "You have not yet paid" in the email body
    When "8" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    When "100" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    And return to current time