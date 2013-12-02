Feature: Payment gateway's own Terms of Service is shown
  In order to make sure each seller has seen the the ToS as required by the payment gateway
  As a marketplace owner
  I want the payment gateway ToS to be shown as combined to the normal terms of service

  @javascript
  Scenario: User views terms on the signup page
    Given community "test" has payments in use via Mangopay
    And I am on the signup page
    When I follow "terms of use"
    Then I should see "MangoPay is used as a payment gateway"

    When I follow "MangoPay terms of use"
    Then I should see "General terms and conditions of use of the electronic money MANGOPAY"

  @javascript
  Scenario: User views terms on the terms page
    Given community "test" has payments in use via Mangopay
    And I am on the terms page
    Then I should see "MangoPay is used as a payment gateway"

    When I follow "MangoPay terms of use"
    Then I should see "General terms and conditions of use of the electronic money MANGOPAY"