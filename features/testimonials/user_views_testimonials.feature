Feature: User views testimonials
  In order to find out whether a user is trustworthy
  As a person who is considering offering something to or requesting something from that user
  I want to be able to view feedback the user has received

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |
    And the community has payments in use via BraintreePaymentGateway
    And Braintree escrow release is mocked
    And "kassi_testperson2" has an active Braintree account
    And there is a listing with title "Skateboard" from "kassi_testperson2" with category "Items" and with transaction type "Selling"
    And there is a pending request "I'd like to buy a skate" from "kassi_testperson1" about that listing

  @javascript
  Scenario: User views testimonials successfully
    Given there are following users:
       | person |
       | kassi_testperson1 |
       | kassi_testperson2 |
       | kassi_testperson3 |
    And there is a listing with title "hammer" from "kassi_testperson3" with category "Items" and with transaction type "Selling"
    And there is a pending request "I offer this" from "kassi_testperson2" about that listing
    And the price of that listing is 20.00 USD
    And there is a payment for that request from "kassi_testperson2" with price "20"
    And the request is confirmed
    And there is feedback about that event from "kassi_testperson2" with grade "0.75" and with text "Well done"

    And there is a listing with title "saw" from "kassi_testperson3" with category "Items" and with transaction type "Selling"
    And there is a pending request "I request this" from "kassi_testperson2" about that listing
    And the price of that listing is 20.00 USD
    And there is a payment for that request from "kassi_testperson2" with price "20"
    And the request is confirmed
    And there is feedback about that event from "kassi_testperson2" with grade "0.25" and with text "You suck"

    And there is a listing with title "massage" from "kassi_testperson2" with category "Services" and with transaction type "Selling"
    And there is a pending request "I request this" from "kassi_testperson3" about that listing
    And the price of that listing is 20.00 USD
    And there is a payment for that request from "kassi_testperson2" with price "20"
    And the request is confirmed
    And there is feedback about that event from "kassi_testperson2" with grade "0.5" and with text "You suck"

    And I am logged in as "kassi_testperson1"

    When I go to the testimonials page of "kassi_testperson3"
    Then I should see "received review"
    And I should see "67%" within "#people-testimonials"
    And I should see "Well done"
    And I should see "You suck" within ".light_red"




