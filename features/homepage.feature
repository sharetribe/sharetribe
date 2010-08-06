Feature: Homepage
  In order to see the latest activity in Kassi
  As a user
  I want see latest offers, requests and transactions on the home page
  
  Scenario: Latest offers on the homepage
    Given a new item offer with title "car spare parts" and with share type "sell"
    When I am on the homepage
    Then I should see "car spare parts"
  
  Scenario: Latest requests on the homepage
    Given a new favor request with title "massage"
    When I am on the homepage
    Then I should see "massage"
  
  @pending
  Scenario: Latest transcations on the homepage
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
  
  
  
  
  
  
  
  
  
  
