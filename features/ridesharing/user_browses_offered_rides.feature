Feature: User browses offered rides
  In order to get from place A to B a cheap and environmentally friendly way
  As a carless Kassi-user
  I want to check if someone is offering ridesharing in Kassi for the same route that I'm going to take
  
  @pending
  Scenario: Browsing all ridesharing offers
    Given there are ridesharing offers in Kassi
    When I click the "rideshare" tab
    And I click the "offered" sub-tab
    Then I should see all the ridesharing offers on the page
  
