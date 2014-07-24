@javascript
Feature: Booking transaction process

  Scenario: User books a snowboard for 7 days
    Given I am logged in as "Booker T"
      And there's a listing "Cool snowboard" from "Owner O" with price "70" per day
     When I make a booking request for that listing for 7 days
     Then I should see that the total price is "490"
     When I enter my payment details
      And I enter a free message "When can I pick it up?"
      And I confirm payment
     Then I should see that the payment was successful
      And I should see when the listing author should contact me

     When I log in as "Owner O"
     Then I should have a new booking request from "Booker T"
     When I accept the booking request
     Then I should see that the request is accepted
      And I should see that I should now deliver the board to "Booker T"

     When the booking period has ended
     Then I should see that the request is completed





  
