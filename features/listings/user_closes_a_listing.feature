Feature: User closes a listing
  In order to announce that a listing is now longer valid and cannot be replied
  As the author of the listing
  I want to be able to close the listing
  
  @pending
  Scenario: User closes a listing successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy,borrow"  
    And I am logged in as "kassi_testperson1"
    When I follow "Hammer"
    And I follow "Close request"
    Then I should see "Request closed" within "#notifications"
    And I should see
  
  
  

  
