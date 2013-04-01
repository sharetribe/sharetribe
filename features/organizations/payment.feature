Feature: User pays after accepted transaction
  In order to pay easily for what I've bought
  As a user
  I want to pay via the platform
  
  @javascript
  Scenario: User goes to payment service, but decides to cancel and comes back
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And community "test" has payments in use
    And "kassi_testperson2" is member of organization that has registered as a seller
    And there is item offer with title "math book" from "kassi_testperson2" and with share type "sell" and with price "12"
    And all listings of "kassi_testperson2" are made with his first organization
    And there is a message "I want to buy" from "kassi_testperson1" about that listing
    And I am logged in as "kassi_testperson2"
    When I follow "inbox-link"
    And I should see "1" within ".inbox-toggle"
    And I follow "conversation_title_link_1"
    And I follow "Accept request"
    And I fill in "conversation_message_attributes_content" with "Ok, then pay!"
    And I press "Send message"
    Then I should see "Accepted"
    When I am logged in as "kassi_testperson1"
    And I follow "inbox-link"
    Then I should see "1" within ".inbox-toggle"
    When I follow "conversation_title_link_1"
    Then I should see "Pay"
    When I follow "Pay"
    Then I should see "New payment"
    And I should see "12 €"
    When I click "#continue_payment"
    Then I should see "Checkout"
    Then I should see "Testi Oy (123456-7)"
    When I click Osuuspankki logo
    And I fill in "id" with "123456"
    And I fill in "pw" with "7890"
    And I press "Jatka"
    And I press "Jatka"
    And I press "Hyväksy"
    And wait for 5 seconds
    Then I should see "Payment successful"
    When I log out
    And the system processes jobs
    And save and open all html emails
    Then "kassi_testperson2@example.com" should receive an email
    When I open the email
    Then I should see "View conversation" in the email body 

  
