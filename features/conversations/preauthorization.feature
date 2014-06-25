@javascript
Feature: Preauthorized payment

  Background:
    Given the community has payments in use via BraintreePaymentGateway with seller commission 10
    And Braintree transaction is mocked

    Given the community has transaction type Sell with name "Selling" and action button label "Buy"
    And that transaction uses payment preauthorization
    And that transaction belongs to category "Items"

    Given there is a listing with title "Skateboard" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And the price of that listing is 50.00 USD

    Given I am logged in as "kassi_testperson2"

  Scenario: User successfully buys Skateboard using preauthorization
    When I am on the listing page
    Then I should see "Skateboard"
    When I follow "Buy"
    Then I should see payment details form for Braintree
    When I fill in my payment details for Braintree
    And I press submit
    Then I should see that I successfully paid 50
    And I should see "Waiting for Kassi to accept the request"



  Scenario: User tries to buy Skateboard but author rejects the request