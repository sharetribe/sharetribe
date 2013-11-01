Feature: User accepts a transaction
  In order to announce to another user that I accept his offer or request
  As an author of a listing describing an offer or a request
  I want to be able to accept the conversation

  # TODO: Payments are currently not supported in request listings. When the support
  # is added back, this test should be used again.
  #
  # @javascript
  # Scenario: User accepts a payment-requiring offer with message and closes the listing
  #   Given there are following users:
  #     | person | 
  #     | kassi_testperson1 |
  #     | kassi_testperson2 |
  #   And community "test" has payments in use
  #   And "kassi_testperson2" is member of organization that has registered as a seller
  #   And there is item request with title "math book" from "kassi_testperson1" and with share type "buy"
  #   And all listings of "kassi_testperson2" are made with his first organization
  #   And there is a message "Math book offer" from "kassi_testperson2" about that listing
  #   And I am logged in as "kassi_testperson1"
  #   When I follow "inbox-link"
  #   And I should see "1" within ".inbox-link"
  #   And I follow "conversation_title_link_1"
  #   And I follow "Accept offer"
  #   And I fill in "conversation_payment_attributes_sum" with "30"
  #   And I fill in "conversation_message_attributes_content" with "Ok, sounds good!"
  #   And I press "Send"
  #   Then I should see "Offer accepted"
  #   And I should see "Ok, sounds good!"
  #   And I should see "Pay" within ".conversation-status"
  #   When I follow "math book"
  #   Then I should see "Listing is closed"
  #   Then I should not see "Close listing"
  #   When the system processes jobs
  #   Then "kassi_testperson1@example.com" should have 0 emails
  #   And "kassi_testperson2@example.com" should receive an email
  #   When I open the email
  #   Then I should see "has accepted your offer" in the email body
  #   When "4" days have passed
  #   And the system processes jobs
  #   Then "kassi_testperson1@example.com" should receive an email
  #   When I open the email with subject "Remember to pay"
  #   Then I should see "You have not yet paid" in the email body
  #   When "8" days have passed
  #   And the system processes jobs
  #   Then "kassi_testperson1@example.com" should have 2 emails
  #   When "100" days have passed
  #   And the system processes jobs
  #   Then "kassi_testperson1@example.com" should have 2 emails
  #   And return to current time
  
  @javascript
  Scenario: User accepts a non-payment-requiring request without message and doesn't close the listing
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor offer with title "Massage" from "kassi_testperson1"
    And there is a message "I request this" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "inbox-link"
    Then I should see "1" within ".inbox-link"
    When I follow "Accept request"
    And I choose "Leave the listing open"
    And I press "Send"
    Then I should see "Accepted" 
    And I should see "to mark the request as completed" within ".conversation-status"
    When I follow "Massage"
    Then I should not see "Listing is closed"
    And I should see "Close listing"
    And the system processes jobs
    When "8" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 2 emails
    When I open the email with subject "Remember to confirm"
    Then I should see "You have not yet confirmed" in the email body
    When "16" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    When "100" days have passed
    And the system processes jobs
    Then "kassi_testperson2@example.com" should have 3 emails
    And return to current time
