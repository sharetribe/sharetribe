Feature: User requests an item in item offer
  In order to borrow an item from another person
  As a person who needs that item
  I want to be able to send a message to the person who offers the item

  Scenario: Requesting an item from the home page
    Given a new item offer with title "Hammer" and with share type "lend"
    And I am logged in with "kassi_testperson2"
    And I am on the homepage
    When I follow "Request item"
    And I fill in "Message:" with "I want to borrow this item"
    And I press "Send the request"
    Then I should see "Item request sent successfully" within "#notifications"
    And I should be on the home page
  
  
  
