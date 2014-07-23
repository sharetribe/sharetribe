@javascript
Feature: New listing with transaction type that uses preauthorization
  In order to allow preauthorized payment for the listing
  As a seller
  I need to have active Braintree account before posting a listing

  Background:
    Given a logged in user "seller_jane"

    Given the community has payments in use via BraintreePaymentGateway with seller commission 10
      And the community has transaction type Sell with name "Selling with preauthorization" and action button label "Buy"
      And that transaction uses payment preauthorization
      And that transaction belongs to category "Tools"

    Given I am on the new listing page

  Scenario: User creates a listing without Braintree account

    When I select category "Items"
      And I select subcategory "Tools"
      And I select transaction type "Selling with preauthorization"

    Then I should warning about missing payment details

  Scenario: User creates a listing

    Given "seller_jane" has an active Braintree account

    When I select category "Items"
      And I select subcategory "Tools"
      And I select transaction type "Selling with preauthorization"

    Then I should see the new listing form