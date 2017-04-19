Feature: User views homepage
  In order to see the latest activity in Sharetribe
  As a user
  I want see latest offers, requests and transactions on the home page

  @javascript
  Scenario: Latest offers on the homepage
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling"
    And there is a listing with title "bike" from "kassi_testperson1" with category "Items" and with listing shape "Selling"
    And that listing is closed
    And there is a listing with title "saw" from "kassi_testperson2" with category "Items" and with listing shape "Requesting"
    When I am on the homepage
    Then I should see "car spare parts"
    And I should not see "bike"
    And I should see "saw"

  @javascript
  Scenario: Latest requests on the homepage
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "massage" from "kassi_testperson2" with category "Services" and with listing shape "Requesting"
    And I am logged in as "kassi_testperson1"
    When I am on the homepage
    Then I should see "massage"
    And I should not see "offer item"

  @javascript
  Scenario: User browses homepage when there is no content
    Given there are following users:
       | person |
       | kassi_testperson1 |
    When I am on the homepage
    When I log in as "kassi_testperson2"
    When there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Requesting"
    And I am on the homepage
    When there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling"
    And I am on the homepage
    Then I should not see "No open item, service or rideshare requests."
    And I should not see "No open item, service or rideshare offers."

  @pending
  Scenario: Latest transactions on the homepage
    Given the latest transaction is "Johnny offered an item drill to Bill" #This Given needs better structure
    When I am on the homepage
    Then I should see "Johnny offered an item drill to Bill"

  @pending
  Scenario: Endless scrolling
    Given there are 13 open offers
    And the oldest offer has title "course books"
    And I am on the home page
    And I do not see "course books"
    When I scroll to the bottom of the page
    And wait for 2 seconds
    Then I should see "course books"

  @javascript
  Scenario: Superadmin views a community he is not a member of
    Given there are following users:
      | person |
      | kassi_testperson1 |
    When I am logged in as "kassi_testperson1"
    And I move to community "test2"
    And "kassi_testperson1" is superadmin
    And I am on the home page
    Then I should not see "Join community"
    And I should see "Post a new listing"

  @javascript
  Scenario: Unlogged user views private community
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And I am not logged in
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with listing shape "Selling"
    And community "test" is private
    When I am on the home page
    Then I should not see "car spare parts"
    And I should see "Sign up"