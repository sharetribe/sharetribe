Feature: User browses offered rides
  In order to get from place A to B a cheap and environmentally friendly way
  As a carless Kassi-user
  I want to check if someone is offering car-pooling in Kassi for the same route that I'm going to take

  Scenario: Browsing all car-pooling offers
    Given there are car-pooling offers in Kassi
    When I click the "rideshare" tab
    And I click the "offered" sub-tab
    Then I should see all the car-pooling offers on the page
  
