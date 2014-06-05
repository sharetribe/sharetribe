Feature: User sends a new message
  In order to contact another user to ask about details related to a listing or just to chat
  As a user
  I want to be able to send a private message to another users

  @javascript
  Scenario: Asking details about a listing
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Hammer" from "kassi_testperson1" with category "Items" and with transaction type "Lending"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "listing-contact"
    And I fill in "Message" with "What kind of hammer is this?"
    And I press "Send message"
    Then I should see "Message sent" within ".flash-notifications"
    And I should see "Hammer" within "#listing-title"
    When I follow inbox link
    And I should see "What kind of hammer is this?"
    And I should not see "Awaiting confirmation from listing author"
    When I log out
    And I log in as "kassi_testperson1"
    And I follow inbox link
    Then I should not see "Accept"
    When I follow "What kind of hammer is this?"
    Then I should not see "Accept"

  @javascript
  Scenario: Trying to ask details about a listing with inadequate information
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Hammer" from "kassi_testperson1" with category "Items" and with transaction type "Lending"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "listing-contact"
    And I press "Send message"
    Then I should see "This field is required."

  @javascript
  Scenario: Asking details about a listing through the listing author box link
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Hammer" from "kassi_testperson1" with category "Items" and with transaction type "Lending"
    And I am logged in as "kassi_testperson2"
    And I am on the homepage
    When I follow "Hammer"
    And I follow "listing-contact"
    Then I should see "Send message to"

  @javascript
  Scenario: Sending message from the profile page
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    And I am on the profile page of "kassi_testperson1"
    When I follow "Contact Kassi"
    And I fill in "Message" with "Random message"
    And I press "Send message"
    And I follow inbox link
    Then I should see "Random message"
    And I should not see "Awaiting confirmation from listing author"
    When I log out
    And I log in as "kassi_testperson1"
    And I follow inbox link
    Then I should not see "Accept"
    When I follow "Random message"
    Then I should not see "Accept"