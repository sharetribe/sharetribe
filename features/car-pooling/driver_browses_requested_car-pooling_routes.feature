Feature: Driver browses requested car pooling routes
  In order to to help others and/or get some gas money with a car ride I'm going to do anyway
  As a driver planning a car ride soon
  I want to browse car-pooling requests to see if someone needs to travel the same way

  Scenario: Browsing all requests
    Given there are car-pooling requests in Kassi
    When I click the "rideshare" tab
    And I click the "requested" sub-tab
    Then I should see all the car-pooling requests on the page
  
  
  
