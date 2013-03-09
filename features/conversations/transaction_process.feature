Feature: Transaction process between two users

  @javascript
  Scenario: Transaction started from a request listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "lend"
    And I am logged in as "kassi_testperson2"

    # Starting the conversation
    When I follow "Hammer"
    And I follow "Borrow this item"
    And I fill in "Message" with "I want to borrow this item"
    And I press "Send the request"
    And the system processes jobs
    And "kassi_tester1@example.com" should receive an email
    And I log out

    When I open the email
    And I follow "View message" in the email
    Then I should see "1" within ".inbox-toggle"
    When I follow "Service offer: Massage"
    And I follow "Accept offer"
    And I fill in "Message" with "Ok, sounds good!"
    And I follow "Send message"
    Then I should see "Offer accepted" within ".conversation-status"
    And I should see "Confirm as done"
    And I should see "1" within ".inbox-toggle"
    And the system processes jobs
    And "kassi_tester2@example.com" should receive an email

    When I follow "Confirm as done"
    And I check "Skip feedback"
    And I follow "Continue"
    Then I should see "Offer confirmed"
    And I should see "Feedback skipped"
  
