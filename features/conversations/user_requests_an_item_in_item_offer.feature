Feature: User requests an item in item offer
  In order to borrow an item from another person
  As a person who needs that item
  I want to be able to send a message to the person who offers the item

  Scenario: Requesting an item from the home page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Request item"
    And I fill in "Message:" with "I want to borrow this item"
    And I press "Send the request"
    Then I should see "Item request sent successfully" within "#notifications"
    And I should be on the home page
  
  Scenario: Requesting an item from the listing page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "Request item"
    And I fill in "Message:" with "I want to borrow this item"
    And I press "Send the request"
    Then I should see "Item request sent successfully" within "#notifications"
    And I should see "Item offer: Hammer" within "h1"
  
  @javascript
  Scenario: Requesting an item from the home page with invalid information
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Request item"
    And I press "Send the request"
    Then I should see "This field is required." within ".error"
  
  @javascript  
  Scenario: Requesting an item from the home page without logging in
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am on the homepage
    When I follow "Request item"
    Then I should see "You must log in to Kassi to send a message to another user." within "#notifications"
    And I should see "Log in to Kassi" within "h2"
  
  
  
