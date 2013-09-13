Feature: Transaction process between two users

  @javascript
  Scenario: Monetary transaction started from an offer listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And community "test" has payments in use
    And "kassi_testperson1" is member of organization that has registered as a seller
    And there is item offer with title "Hammer" from "kassi_testperson1" and with share type "sell" and with price "20"
    And all listings of "kassi_testperson1" are made with his first organization
    And I am logged in as "kassi_testperson2"

    # Starting the conversation
    When I follow "Hammer"
    And I follow "Buy this item"
    And I fill in "Message" with "I want to buy this item"
    And I press "Send"
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
    And I press "Send"
    Then I should see "Accepted"
    And I should see "to pay"
    And I should not see "1" within ".inbox-toggle"
    And the system processes jobs
    And "kassi_testperson2@example.com" should receive an email
    And I log out
    
    # Paying with Checkout
    When I open the email
    And I follow "Pay now" in the email
    And I press "Continue"
    And I click Osuuspankki logo
    And I fill in "id" with "123456"
    And I fill in "pw" with "7890"
    And I press "Jatka"
    And I press "Jatka"
    And I press "Hyväksy"
    And wait for 5 seconds
    Then I should see "Payment successful"
    When the system processes jobs
    Then "kassi_testperson2@example.com" should have 2 emails
    And "kassi_testperson1@example.com" should have 2 emails
    And I log out
    When I open the email with subject "You have received a new payment"
    Then I should see "You have been paid" in the email body
    
    # Confirming as done
    When I log in as "kassi_testperson2"
    And I follow "inbox-link"
    And I follow "View conversation" in the email
    And I follow "Mark completed"
    And I choose "Skip feedback"
    And I press "Continue"
    Then I should see "Completed"
    And I should see "Feedback skipped"
    And the system processes jobs
    And I should not see "1" within ".inbox-toggle"
    And "kassi_testperson1@example.com" should have 3 emails
    And I log out
    
    # Giving feedback
    When I open the email with subject "Request completed - remember to give feedback"
    And I follow "Give feedback" in the email
    And I click "#positive-grade-link"
    And I fill in "How did things go?" with "Everything was great!"
    And "kassi_testperson2@example.com" should have 2 emails
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
    
    # Viewing badge disabled for now
    # When I open the email with subject "You have achieved a badge"
    # Then I should see "You have achieved a badge 'First event'" in the email body
    
  @javascript
  Scenario: Non-monetary ransaction started from a request listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "borrow"
    And I am logged in as "kassi_testperson2"

    # Starting the conversation
    When I follow "Hammer"
    And I follow "Offer to lend this item"
    And I fill in "Message" with "I can lend this item"
    And I press "Send"
    And the system processes jobs
    And "kassi_testperson1@example.com" should receive an email
    When I follow "inbox-link"
    Then I should see "to accept the offer"
    And I log out

    # Accepting
    When I open the email
    And I follow "View message" in the email
    Then I should see "1" within ".inbox-toggle"
    When I follow "Accept offer"
    And I fill in "conversation_message_attributes_content" with "Ok, that works!"
    And I press "Send"
    Then I should see "Mark completed"
    And I should not see "1" within ".inbox-toggle"
    And the system processes jobs
    And "kassi_testperson2@example.com" should receive an email
    And I log out
    
    # Confirming as done
    When I open the email
    And I follow "View conversation" in the email
    Then I should see "to mark the request as completed"
    When I log out
    And I log in as "kassi_testperson1"
    And I follow "inbox-link"
    And I follow "Mark completed"
    And I choose "Skip feedback"
    And I press "Continue"
    Then I should see "Completed"
    And I should see "Feedback skipped"
    And the system processes jobs
    And I should not see "1" within ".inbox-toggle"
    And "kassi_testperson2@example.com" should have 2 emails
    And I log out
    
    # Giving feedback
    When I open the email with subject "Request completed - remember to give feedback"
    And I follow "Give feedback" in the email
    And I click "#positive-grade-link"
    And I fill in "How did things go?" with "Everything was great!"
    And "kassi_testperson1@example.com" should have 1 email
    And I press "send_testimonial_button"
    Then I should see "Feedback sent to" within ".flash-notifications"
    And I should see "Feedback given" within ".conversation-status"
    And the system processes jobs
    And I log out
    And "kassi_testperson1@example.com" should have 2 emails
    
    # Viewing feedback
    When I open the email with subject "has given you feedback in Sharetribe"
    And I follow "View feedback" in the email
    Then I should see "Everything was great!"
    
    # Viewing badge is currently disabled
    # When I open the email with subject "You have achieved a badge"
    #     Then I should see "You have achieved a badge 'First event'" in the email body