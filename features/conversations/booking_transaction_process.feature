@javascript
Feature: Booking transaction process

  Background:
    Given a user "owner"
      And a logged in user "booker"

    Given the community has payments in use via BraintreePaymentGateway with seller commission 10
      And the community has transaction type Rent with name "Renting" and action button label "Buy"
      And the community shows the price of listing per "day"

  Scenario: User books a snowboard for 7 days
    Given there is a listing with title "Cool snowboard" from "owner" with category "Items" and with transaction type "Renting"
      And the price of that listing is 70.0 USD
     When I make a booking request for that listing for 7 days
     Then I should see that the total price is "490"
     When I enter my payment details
      And I confirm payment
     Then I should see that the payment was successful
      And I should see when the listing author should contact me

     When I log in as "owner"
     Then I should have a new booking request from "booker"
     When I accept the booking request
     Then I should see that the request is accepted
      And I should see that I should now deliver the board to "booker"

     When the booking period has ended
     Then I should see that the request is completed






