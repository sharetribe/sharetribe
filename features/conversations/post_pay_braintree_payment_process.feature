@javascript
Feature: Post pay Braintree payment process

  Background:
    Given the community has payments in use via BraintreePaymentGateway with seller commission 10
      And Braintree transaction is mocked

    Given a user "seller_jane"
      And a user "buyer_bob"

    Given the community has transaction type Sell with name "Selling" and action button label "Buy"
      And that transaction does not use payment preauthorization
      And that transaction belongs to category "Items"

    Given there is a listing with title "Skateboard" from "seller_jane" with category "Items" and with transaction type "Selling"
      And the price of that listing is 50.00 USD

  Scenario: User successfully buys Skateboard using post pay
    Given I am logged in as "buyer_bob"

    Given Braintree escrow release is mocked
      And Braintree merchant creation is mocked

    When I buy that listing
    Then I should see that the price of a listing is "$50"
     And I should send a message to "seller_jane"

    When I send initial message to "seller_jane"
    Then I should see that buy message has been sent

    When I log in as "seller_jane"
     And I accept the "I want to buy this item" request for that listing for post pay
    Then I should see that I should fill in payout details

    When I follow link to fill in Braintree payout details
     And I fill in Braintree account details
     And I press submit
    Then I should see "Account status: pending"
     And Braintree webhook "sub_merchant_account_approved" with username "seller_jane" is triggered

    When I refresh the page
    Then I should see "Account status: active"

    When I accept the "I want to buy this item" request for that listing for post pay
     And I approve the request for that listing for post pay
    Then I should see that the request is waiting for buyer to pay


    When I log in as "buyer_bob"
     And I buy approved request "accepted the request"
    Then I should see payment details form for Braintree

    When I fill in my payment details for Braintree
    Then I should see that I successfully paid 50

    When I confirm the request for that listing
    Then I should see that the request was confirmed
