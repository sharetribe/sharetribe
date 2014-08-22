@javascript
Feature: Booking transaction process

  Background:
    Given Braintree transaction is mocked

    Given a user "owner"
      And a logged in user "booker"
      And "owner" has an active Braintree account

    Given the community has payments in use via BraintreePaymentGateway with seller commission 10
      And the community has transaction type Rent with name "Renting" and action button label "Buy"
      And that transaction uses payment preauthorization
      And that transaction type shows the price of listing per day

  Scenario: User books a snowboard for 7 days
    Given there is a listing with title "Cool snowboard" from "owner" with category "Items" and with transaction type "Renting"
      And the price of that listing is 70.0 USD
      And Braintree submit to settlement is mocked
      And Braintree escrow release is mocked

     When I make a booking request for that listing for 7 days
     Then I should see that the total price is "490"

      And I should see payment details form for Braintree

     When I fill in my payment details for Braintree
     Then I should see that I successfully paid 490
      And author "owner" should be notified about the request from starter "booker"
      And I should see that the request is waiting for seller acceptance

     When I log in as "owner"
      And I accepts the request for that listing

     Then I should see that the request is waiting for buyer confirmation
      And I should see that I should now deliver the board
      And author "owner" and starter "booker" should receive receipts for payment

     When the booking is automatically confirmed
      And I should see that the request is completed
      And author "owner" and starter "booker" should be notified about automatic confirmation
