Feature: User views homepage
  In order to see the latest activity in Kassi
  As a user
  I want see latest offers, requests and transactions on the home page
  
  @javascript
  Scenario: Latest offers on the homepage
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And there is item offer with title "bike" from "kassi_testperson1" and with share type "sell"
    And that listing is closed
    And there is item request with title "saw" from "kassi_testperson2" and with share type "buy"
    And visibility of that listing is "this_community"
    When I am on the homepage
    And I should see "car spare parts"
    And I should see "Request item"
    And I should not see "bike"
    And I should not see "saw"
    And I log in as "kassi_testperson1"
    Then I should see "saw"
    And I should see "car spare parts"
    And I should not see "bike"
    And I should not see "Request item"
    And I should see "Offer your item"
  
  @javascript
  Scenario: Latest requests on the homepage
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "massage" from "kassi_testperson2"
    And I am logged in as "kassi_testperson1"
    When I am on the homepage
    Then I should see "massage"
    And I should not see "offer item"
  
  @javascript
  Scenario: User browses homepage with requests with visibility settings
     Given there are following users:
       | person | 
       | kassi_testperson1 |
     And there is item request with title "car spare parts" from "kassi_testperson2" and with share type "buy"
     And visibility of that listing is "this_community"
     And there is favor request with title "massage" from "kassi_testperson1"
     And there is housing request with title "place to live" and with share type "rent"
     And visibility of that listing is "disabled"
     And I am on the home page page
     And I should not see "car spare parts"
     And I should see "massage"
     And I should not see "place to live"
     And I should see "Additionally there is one other request, but that is visible only to registered members."
     When I log in as "kassi_testperson1"
     Then I should see "car spare parts"
     And I should see "massage"
     And I should not see "place to live"
     
  @javascript
  @subdomain2
  Scenario: User browses homepage in a different subdomain
    Given there are following users:
       | person | 
       | kassi_testperson1 |
       | kassi_testperson2 |
    And there is item request with title "car spare parts" from "kassi_testperson1" and with share type "buy"
    And visibility of that listing is "this_community"
    And there is favor request with title "massage" from "kassi_testperson2"
    And visibility of that listing is "communities"
    And there is item request with title "saw" from "kassi_testperson2" and with share type "buy"
    And visibility of that listing is "communities"
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
    Then I should see "No item, favor or rideshare requests visible to non-logged-in users."
    And I should see "No item, favor or rideshare offers visible to non-logged-in users."
    When I log in as "kassi_testperson2"
    Then I should see "No open item, favor or rideshare requests."
    And I should see "No open item, favor or rideshare offers."
    When there is item request with title "car spare parts" from "kassi_testperson1" and with share type "buy"
    And I am on the homepage
    Then I should not see "No open item, favor or rideshare requests."
    And I should see "No open item, favor or rideshare offers."
    When there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And I am on the homepage
    Then I should not see "No open item, favor or rideshare requests."
    And I should not see "No open item, favor or rideshare offers."
  
  @javascript
  Scenario: User browses homepage when there are only private listings. He should see blank slates
     Given there are following users:
       | person | 
       | kassi_testperson1 |
     And there is item offer with title "car spare parts" from "kassi_testperson2" and with share type "sell"
     And visibility of that listing is "this_community"
     And there is housing request with title "place to live" and with share type "rent"
     And visibility of that listing is "this_community"
     And I am on the home page page
     And I should not see "car spare parts"
     And I should not see "place to live"
     And I should see "There is already one request, but that is visible only to registered members."
     And I should see "There is already one offer, but that is visible only to registered members."
     When there is item request with title "bike parts" from "kassi_testperson2" and with share type "buy"
     And visibility of that listing is "this_community"
     And I am on the homepage
     Then I should not see "bike parts"
     And I should see "There are already 2 requests, but those are visible only to registered members."
  
  
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