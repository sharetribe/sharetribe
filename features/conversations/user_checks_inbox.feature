@javascript
Feature: User checks inbox
  In order to view my received and sent messages
  As a user
  I want to be able to go to my inbox and view my messages

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |

  Scenario: Viewing messages
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    Then I should see "Massage" within "#conversations"
    And I should see "Test message" within "#conversations"

  Scenario: Viewing a single conversation
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    And I follow "Test message"
    Then I should see "Inbox | Conversation with Kassi T" within "h1"

  Scenario: Viewing received messages when there are multiple messages from different senders
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And I am logged in as "kassi_testperson1"
    Then I should see that there are no new messages

    Given there is a message "Reply to massage" from "kassi_testperson2" about that listing
    When I refresh the page
    Then I should see that there is 1 new message

    Given there is a message "Another test" from "kassi_testperson3" about that listing
    When I refresh the page
    Then I should see that there are 2 new messages

    Given there is a reply "great" to that message by "kassi_testperson1"
    When I refresh the page
    Then I should see that there is 1 new message

    Given there is a listing with title "Apartment" from "kassi_testperson2" with category "Spaces" and with transaction type "Selling"
    And there is a message "Test1" from "kassi_testperson3" about that listing
    And there is a listing with title "Hammer" from "kassi_testperson2" with category "Items" and with transaction type "Lending"
    And there is a message "Test2" from "kassi_testperson1" about that listing
    And there is a listing with title "Helsinki - Turku" from "kassi_testperson2" with category "Services" and with transaction type "Selling services"
    And there is a message "Test3" from "kassi_testperson1" about that listing
    When I refresh the page
    Then I should see that there is 1 new message

    And there is a reply "Fine" to that message by "kassi_testperson2"
    When I refresh the page
    Then I should see that there are 2 new messages

    When I follow inbox link
    Then I should see "Reply to massage"
    And I should see "Massage"
    And I should see "great"
    And I should not see "Test1"
    And I should see "Test2"
    And I should see "Helsinki - Turku"
    And I should see "Fine"
    And I follow "Fine"
    And I follow inbox link
    And I should not see "Fine" within ".unread"
    And I should see that there is 1 new message

  Scenario: Viewing sent messages when there are multiple messages from different senders
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a message "Reply to massage" from "kassi_testperson2" about that listing
    And there is a message "Another test" from "kassi_testperson3" about that listing
    And there is a reply "Ok" to that message by "kassi_testperson1"
    And there is a listing with title "Apartment" from "kassi_testperson2" with category "Spaces" and with transaction type "Selling"
    And there is a message "Test1" from "kassi_testperson3" about that listing
    And there is a listing with title "Hammer" from "kassi_testperson2" with category "Items" and with transaction type "Lending"
    And there is a message "Test2" from "kassi_testperson1" about that listing
    And there is a listing with title "Helsinki - Turku" from "kassi_testperson2" with category "Services" and with transaction type "Selling services"
    And there is a message "Test3" from "kassi_testperson1" about that listing
    And there is a reply "Fine" to that message by "kassi_testperson2"
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    Then I should see "Ok"
    And I should see "Massage"
    And I should not see "Test1"
    And I should see "Test2"
    And I should see "Hammer"
    And I should see "Helsinki - Turku"
    And I should see "Fine"

  Scenario: Trying to view inbox without logging in
    And I am not logged in
    When I try to go to inbox of "kassi_testperson1"
    Then I should see "You must log in to Sharetribe to view your inbox." within ".flash-notifications"
    And I should see "Log in to Sharetribe" within "h1"
