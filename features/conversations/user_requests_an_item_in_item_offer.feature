Feature: User requests an item in item offer
  In order to borrow an item from another person
  As a person who needs that item
  I want to be able to send a message to the person who offers the item
  
  Scenario: Borrowing an item from the listing page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "Borrow this item"
    And I fill in "Message:" with "I want to borrow this item"
    And I press "Send the request"
    Then I should see "Message sent" within "#notifications"
    And I should see "Lending: Hammer" within "h1"
  
  @javascript
  Scenario: Borrowing an item with invalid information
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "Borrow this item"
    And I press "Send the request"
    Then I should see "This field is required." within ".error"
  
  @javascript  
  Scenario: Requesting an item without logging in and then logging in
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "Borrow this item"
    Then I should see "You must log in to Sharetribe to send a message to another user." within "#notifications"
    And I should see "Log in to Sharetribe" within "h2"
    When I log in as "kassi_testperson2"
    Then I should see "Item request: Hammer"
  
  @javascript  
  Scenario: Trying to request an item without logging in and then logging in as the item owner
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    Given there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "Borrow this item"
    Then I should see "You must log in to Sharetribe to send a message to another user." within "#notifications"
    And I should see "Log in to Sharetribe" within "h2"
    When I log in as "kassi_testperson1"
    Then I should see "You cannot send a message to yourself" within "#notifications"
    And I should see "Lending: Hammer"
