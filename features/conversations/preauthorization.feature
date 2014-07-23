@javascript
Feature: Preauthorized payment

  Background:
    Given the community has payments in use via BraintreePaymentGateway with seller commission 10
      And Braintree transaction is mocked

    Given a user "seller_jane"
      And a user "buyer_bob"

    Given the community has transaction type Sell with name "Selling" and action button label "Buy"
      And that transaction uses payment preauthorization
      And that transaction belongs to category "Items"

    Given there is a listing with title "Skateboard" from "seller_jane" with category "Items" and with transaction type "Selling"
      And the price of that listing is 50.00 USD

  Scenario: User successfully buys Skateboard using preauthorization
    Given I am logged in as "buyer_bob"

    Given Braintree submit to settlement is mocked
      And Braintree escrow release is mocked

     When I buy that listing
     Then I should see payment details form for Braintree

     When I fill in my payment details for Braintree
     Then I should see that I successfully paid 50
      And I should see that the request is waiting for seller acceptance

     When I log in as "seller_jane"
      And I accepts the request for that listing
     Then I should see that the request is waiting for buyer confirmation

     When I log in as "buyer_bob"
      And I confirm the request for that listing
     Then I should see that the request was confirmed

  Scenario: User buys Skateboard using preauthorization with automatic confirmation
    Given I am logged in as "buyer_bob"

    Given Braintree submit to settlement is mocked
      And Braintree escrow release is mocked

     When I buy that listing
     Then I should see payment details form for Braintree

     When I fill in my payment details for Braintree
     Then I should see that I successfully paid 50
      And I should see that the request is waiting for seller acceptance

     When I log in as "seller_jane"
      And I accepts the request for that listing
     Then I should see that the request is waiting for buyer confirmation

     When 20 days have passed
      And the system processes jobs
      And I refresh the page
     Then I should see that the request is confirmed

  Scenario: User buys Skateboard but seller doesn't respond
    Given I am logged in as "buyer_bob"

    Given Braintree void transaction is mocked

     When I buy that listing
     Then I should see payment details form for Braintree

     When I fill in my payment details for Braintree
     Then I should see that I successfully paid 50
      And I should see that the request is waiting for seller acceptance

     When the seller does not respond the request within 5 days
     Then I should see that the request was rejected