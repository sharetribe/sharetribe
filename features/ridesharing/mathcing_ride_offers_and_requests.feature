Feature: Mathcing ride offers and requests
  In order to match ridesharing requests and offers flexibly
  As a service responsible
  I want that offers and requests are matched if the difference between the announced start times is not greater than 15 minutes
  
  @pending
  Scenario: matching request and offer with different times
    Given there is an offer to share a ride from "tkk" to "taik" at "15:15"
    When someone requests a ride from "tkk" to "taik" at "15:00"
    Then The requester should get a message of possible driver been found
    
