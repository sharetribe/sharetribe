Feature: Driver browses requested car pooling routes
  In order to to help others and/or get some gas money with a car ride I'm going to do anyway
  As a driver planning a car ride soon
  I want to browse ridesharing requests to see if someone needs to travel the same way

  @pending
  Scenario: Browsing all requests
    Given there are ridesharing requests in Kassi
    And I am on the requests page
    And I follow "rideshare"
    Then I should see all the ridesharing requests on the page
  
  
  
