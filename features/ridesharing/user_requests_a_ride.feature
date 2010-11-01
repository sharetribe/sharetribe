Feature: User requests a ride
  In order to get from place A to B a cheap and environmentally friendly way
  As a carless Kassi-user
  I want to be able to ask if there is anyone driving the same way that could pick me up
  
  @pending
  Scenario: Requesting ridesharing by SMS
    Given I want to get somewhere
    When I send SMS "request tkk taik 14:00" to Kassi
    Then A request for ridesharing from "tkk" to "taik" starting at "14:00" should be added to Kassi
  
  @pending
  Scenario: Offering ridesharing from current location by SMS
    Given I want to get somewhere
    And my phone location can be requested by Kassi
    When I send SMS "request hse 9:30" to Kassi
    Then A request for ridesharing from my current location to "hse" starting at "9:30" should be added to Kassi
  
  @pending
  Scenario: Offering ridesharing from current location by SMS and starting right now
    Given I want to get somewhere
    And I want to start about now
    And my phone location can be requested by Kassi
    When I send SMS "request hse" to Kassi
    Then A request for ridesharing from my current location to "hse" starting at current time should be added to Kassi
  
  @pending
  Scenario: Matching potential driver is found
    Given I have requested a shared ride from "taik" to "tkk" at "13:00"
    And user "Simo" has phone number "0501234567" in his public profile
    And my username is "Laura"
    And the allowed difference in starting times is 15 minutes by default
    When a user "Simo" adds an offer to get a ride from "taik" to "tkk" at "13:10"
    Then I should get a SMS "Simo is driving from taik to tkk at 13:10. You can call him at 0501234567. To pay some gas money to Simo, reply 'SEND Xe' where X is the amount (max.90e)"


