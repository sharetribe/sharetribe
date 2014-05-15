Feature: User views homepage
  In order to see the latest activity in Sharetribe
  As a user
  I want see latest offers, requests and transactions on the home page

  @javascript
  Scenario: Latest offers on the homepage
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And there is a listing with title "bike" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And that listing is closed
    And there is a listing with title "saw" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
    And privacy of that listing is "private"
    When I am on the homepage
    Then I should see "car spare parts"
    And I should not see "bike"
    And I should not see "saw"
    When I log in as "kassi_testperson1"
    Then I should see "saw"
    And I should see "car spare parts"
    And I should not see "bike"

  @javascript
  Scenario: Latest requests on the homepage
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "massage" from "kassi_testperson2" with category "Services" and with transaction type "Requesting"
    And I am logged in as "kassi_testperson1"
    When I am on the homepage
    Then I should see "massage"
    And I should not see "offer item"

  @javascript
  Scenario: User browses homepage with requests with visibility settings
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
    And privacy of that listing is "private"
    And there is a listing with title "massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a listing with title "place to live" from "kassi_testperson1" with category "Spaces" and with transaction type "Requesting"
    And visibility of that listing is "all_communities"
    And privacy of that listing is "private"
    And I am on the home page page
    And I should not see "car spare parts"
    And I should see "massage"
    And I should not see "place to live"
    When I log in as "kassi_testperson1"
    Then I should see "car spare parts"
    And I should see "massage"
    And I should see "place to live"

  @javascript
  @subdomain2
  Scenario: User browses homepage in a different subdomain
    Given there are following users:
       | person |
       | kassi_testperson1 |
       | kassi_testperson2 |
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with transaction type "Requesting"
    And privacy of that listing is "private"
    And that listing belongs to community "test"
    And there is a listing with title "massage" from "kassi_testperson2" with category "Services" and with transaction type "Requesting"
    And visibility of that listing is "all_communities"
    And that listing belongs to community "test"
    And there is a listing with title "saw" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
    And visibility of that listing is "all_communities"
    And privacy of that listing is "private"
    And that listing belongs to community "test"
    And that listing is visible to members of community "test2"
    When I am on the homepage
    Then I should not see "car spare parts"
    And I should not see "massage"
    And I should not see "saw"
    When I log in as "kassi_testperson2"
    Then I should not see "car spare parts"
    And I should not see "massage"
    And I should see "saw"

  @javascript
  Scenario: User browses homepage when there is no content
    Given there are following users:
       | person |
       | kassi_testperson1 |
    When I am on the homepage
    When I log in as "kassi_testperson2"
    When there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with transaction type "Requesting"
    And I am on the homepage
    When there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And I am on the homepage
    Then I should not see "No open item, service or rideshare requests."
    And I should not see "No open item, service or rideshare offers."

  @javascript
  Scenario: User browses homepage when there are only private listings. He should see blank slates
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And there is a listing with title "car spare parts" from "kassi_testperson2" with category "Items" and with transaction type "Selling"
    And privacy of that listing is "private"
    And there is a listing with title "place to live" with category "Spaces" and with transaction type "Requesting"
    And privacy of that listing is "private"
    And I am on the home page page
    And I should not see "car spare parts"
    And I should not see "place to live"
    When there is a listing with title "bike parts" from "kassi_testperson2" with category "Items" and with transaction type "Requesting"
    And privacy of that listing is "private"
    And I am on the homepage
    Then I should not see "bike parts"

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
    And there is a listing with title "car spare parts" from "kassi_testperson1" with category "Items" and with transaction type "Selling"
    And community "test" is private
    When I am on the home page
    Then I should not see "car spare parts"
    And I should see "Sign up"