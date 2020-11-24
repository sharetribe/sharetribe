@javascript
Feature: User views a single listing
  In order to value
  As a role
  I want feature

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"

  @only_without_asi
  Scenario: User views a listing that he is allowed to see
    And I am on the home page
    When I follow "Massage"
    Then I should see "Massage"
    When I am logged in as "kassi_testperson1"
    And I am on the home page
    And I follow "Massage"

  @only_without_asi
  Scenario: User views a listing with price
    And the price of that listing is 20.55 USD
    And I am on the home page
    When I follow "Massage"
    Then I should see "Massage"
    And I should see "$20.55"
    When I am logged in as "kassi_testperson1"
    And I am on the home page
    And I follow "Massage"

  Scenario: User tries to view a listing restricted viewable to community members without logging in
    Given I am not logged in
    And this community is private
    And I am on the home page
    When I go to the listing page
    Then I should see "You must log in to view this content"

  Scenario: User views listing created
    Given I am not logged in
    When I go to the listing page
    Then I should not see "Listing created"
    When listing publishing date is shown in community "test"
    And I go to the listing page
    Then I should see "Listing created"

  Scenario: User views listing and payments are not enabled
    And there is a listing with title "Lecture" from "kassi_testperson1" with category "Services" and with listing shape "Lending"
    And I am on the home page
    When I follow "Lecture"
    Then I should see "Borrow this item"
    Then I should not see payment logos

  Scenario: User views listing and payments are enabled
    Given community "test" has a listing shape offering services per hour
    And community "test" has payment method "paypal" provisioned
    And community "test" has payment method "paypal" enabled by admin
    And I have confirmed paypal account as "kassi_testperson1"
    And there is a listing with title "Lecture" from "kassi_testperson1" with category "Services" and with listing shape "Offering Services"
    And I am on the home page
    When I follow "Lecture"
    Then I should see "Request Services"
    Then I should see payment logos


