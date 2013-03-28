Feature: Transaction process between two users

  @javascript
  Scenario: Transaction started from an offer listing
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
    And "kassi_testperson1@example.com" should receive an email
    When I follow "inbox-link"
    Then I should see "to accept the request"
    And I log out

    # Accepting
    When I open the email
    And I follow "View message" in the email
    Then I should see "1" within ".inbox-toggle"
    When I follow "Accept request"
    And I fill in "conversation_message_attributes_content" with "Ok, that works!"
    And I press "Send message"
    Then I should see "Request accepted"
    And I should see "to mark the request as completed"
    And I should not see "1" within ".inbox-toggle"
    And the system processes jobs
    And "kassi_testperson2@example.com" should receive an email
    And I log out
    
    # Confirming as done
    When I open the email
    And I follow "View conversation" in the email
    # TODO Should be able to show also non-confirmed conversations as unread
    # And I should see "1" within ".inbox-toggle"
    And I follow "View conversation" in the email
    And I follow "Mark completed"
    And I choose "Skip feedback"
    And I press "Continue"
    Then I should see "Request completed"
    And I should see "Feedback skipped"
    And the system processes jobs
    And I should not see "1" within ".inbox-toggle"
    And "kassi_testperson1@example.com" should have 2 emails
    And I log out
    
    # Giving feedback
    When I open the email with subject "Request completed - remember to give feedback"
    And I follow "Give feedback" in the email
    And I click "#positive-grade-link"
    And I fill in "How did things go?" with "Everything was great!"
    And "kassi_testperson2@example.com" should have 1 email
    And I press "send_testimonial_button"
    Then I should see "Feedback sent to" within ".flash-notifications"
    And I should see "Feedback given" within ".conversation-status"
    And the system processes jobs
    And I log out
    And "kassi_testperson2@example.com" should have 3 emails
    
    # Viewing feedback
    When I open the email with subject "has given you feedback in Sharetribe"
    And I follow "View feedback" in the email
    Then I should see "Everything was great!"
    
    # Viewing badge
    When I open the email with subject "You have achieved a badge"
    Then I should see "You have achieved a badge 'First event'" in the email body