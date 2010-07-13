Feature: User requests a ride
  In order to get from place A to B a cheap and environmentally friendly way
  As a carless Kassi-user
  I want to be able to ask if there is anyone driving the same way that could pick me up
  
  Scenario: Requesting car-pooling by SMS
    Given I want to get somewhere
    When I send SMS "request tkk taik 14:00" to Kassi
    Then A request for car-pooling ride from "tkk" to "taik" starting at "14:00" should be added to Kassi
  
  Scenario: Offering car-pooling from current location by SMS
    Given I want to get somewhere
    And my phone location can be requested by Kassi
    When I send SMS "request hse 9:30" to Kassi
    Then A request for car-pooling ride from my current location to "hse" starting at "9:30" should be added to Kassi
  
  Scenario: Matching potential driver is found
    Given I have requested a car-pooling ride from "taik" to "tkk" at "13:00"
    And user "Simo" has phone number "0501234567" in his public profile
    And my username is "Laura"
    When a user "Simo" adds an offer to get a ride from "taik" to "tkk" at "13:00"
    Then I should get a SMS "Simo is driving from taik to tkk at 13:00. You can call him at 0501234567"


