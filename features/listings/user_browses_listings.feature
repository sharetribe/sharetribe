Feature: User browses listings
  In order to find out what kind of offers and requests there are available in Kassi
  As a person who needs something or has something
  I want to be able to browse offers and requests

  Scenario: User browses offers page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "car spare parts" from "kassi_testperson1" and with share type "sell"
    And there is favor request with title "massage" from "kassi_testperson1"
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson1"
    And there is housing offer with title "Housing" from "kassi_testperson2" and with share type "sell"
    And there is item request with title "bike" from "kassi_testperson1" and with share type "rent"
    And that listing is closed
    And there is favor offer with title "sewing" from "kassi_testperson1"
    And that listing is closed
    And I am on the home page
    When I follow "Offers"
    And I should see
    
  @pending
  Scenario: User browses requests page
    Given context
    When event
    Then outcome
  
    
  
  
  
