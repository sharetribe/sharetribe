Feature: Driver browses requested car pooling routes
  In order to to help others and/or get some gas money with a car ride I'm going to do anyway
  As a driver planning a car ride soon
  I want to browse ridesharing requests to see if someone needs to travel the same way

  
  Scenario: Browsing all ridesharing requests
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is rideshare request from "tkk" to "kamppi" by "kassi_testperson1"
    And there is rideshare request from "Oulu" to "Helsinki" by "kassi_testperson2"
    And there is item offer with title "axe" from "kassi_testperson2" and with share type "lend,trade"
    And I am on the requests page
    When I follow "Rideshare"
    Then I should see "tkk - kamppi"
    And I should see "Oulu - Helsinki"
    But I should not see "axe"
  
  
  
