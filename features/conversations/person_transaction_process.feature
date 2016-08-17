Feature: Transaction process between two users

  @javascript
  Scenario: Free message conversation for non-monetary transaction
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Hammer" from "kassi_testperson1" with category "Items" and with listing shape "Requesting"
    And I am logged in as "kassi_testperson2"

    # Starting the conversation
    When I follow "Hammer"
    And I press "Offer"
    And I fill in "message" with "I can lend this item"
    And I press "Send"
    And the system processes jobs
    And "kassi_testperson1@example.com" should receive an email
    And I log out

    # Replying
    When I open the email
    And I follow "View message" in the email
    And I log in as "kassi_testperson1"
    And I fill in "message[content]" with "Ok, that works!"
    And I press "Send reply"
    Then I should see "Ok, that works!" in the message list
    And the system processes jobs
    Then "kassi_testperson2@example.com" should receive an email
    And I log out
