Feature: User sends a new message
  In order to contact another user to ask about details related to a listing or just to chat
  As a user
  I want to be able to send a private message to another users
  
  Scenario: Asking details about a listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "Send private message to renter"
    And I fill in "Message:" with "What kind of hammer is this?"
    And I press "Send the request"
    Then I should see "Message sent" within "#notifications"
    And I should see "Lending: Hammer" within "h1"
  
  Scenario: Asking details about a listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "Send private message to renter"
    And I fill in "Message:" with "What kind of hammer is this?"
    And I press "Send the request"
    Then I should see "Message sent" within "#notifications"
    And I should see "Lending: Hammer" within "h1"

  
