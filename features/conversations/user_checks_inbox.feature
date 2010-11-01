Feature: User checks inbox
  In order to view my received and sent messages
  As a user
  I want to be able to go to my inbox and view my messages
  
  @javascript
  Scenario: Viewing received messages
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    Then I should see "Messages" within "h1"
    And I should see "Favor offer: Massage" within "h3"
    And I should see "Received" within ".inbox_tab_selected"
    And I should see "Sent" within ".inbox_tab_unselected"
    And I should see "Test message" within "span"

  @javascript
  Scenario: Viewing sent messages
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson2"
    And there is a message "Test message" from "kassi_testperson1" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Sent"
    Then I should see "Messages" within "h1"
    And I should see "Favor offer: Massage" within "h3"
    And I should see "Test message" within "span"
  
  @javascript
  Scenario: Viewing a single conversation in received messages
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Favor offer: Massage"
    Then I should see "Favor offer: Massage" within "h2"
  
  @javascript
  Scenario: Viewing received messages when there are multiple messages from different senders
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "Reply to massage" from "kassi_testperson2" about that listing
    And there is a message "Another test" from "kassi_testperson3" about that listing
    And there is a reply "Ok" to that message by "kassi_testperson1"
    And there is housing offer with title "Apartment" from "kassi_testperson2" and with share type "sell"
    And there is a message "Test1" from "kassi_testperson3" about that listing
    And there is item offer with title "Hammer" from "kassi_testperson2" and with share type "lend"
    And there is a message "Test2" from "kassi_testperson1" about that listing
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson2"
    And there is a message "Test3" from "kassi_testperson1" about that listing
    And there is a reply "Fine" to that message by "kassi_testperson2"
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    Then I should see "Reply to massage" within ".unread"
    And I should see "Favor offer: Massage" within "h3"
    And I should not see "Another test" within ".unread"
    And I should not see "Test1"
    And I should not see "Test2"
    And I should see "Rideshare request: Helsinki - Turku" within "h3"
    And I should see "Fine" within ".unread"
    And I should see "3" within "#logged_in_messages_icon"
    And I follow "Fine"
    And I follow "Messages"
    And I should not see "Fine" within ".unread"
    And I should see "2" within "#logged_in_messages_icon"  
  
  @javascript
  Scenario: Viewing sent messages when there are multiple messages from different senders
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And there is a message "Reply to massage" from "kassi_testperson2" about that listing
    And there is a message "Another test" from "kassi_testperson3" about that listing
    And there is a reply "Ok" to that message by "kassi_testperson1"
    And there is housing offer with title "Apartment" from "kassi_testperson2" and with share type "sell"
    And there is a message "Test1" from "kassi_testperson3" about that listing
    And there is item offer with title "Hammer" from "kassi_testperson2" and with share type "lend"
    And there is a message "Test2" from "kassi_testperson1" about that listing
    And there is rideshare offer from "Helsinki" to "Turku" by "kassi_testperson2"
    And there is a message "Test3" from "kassi_testperson1" about that listing
    And there is a reply "Fine" to that message by "kassi_testperson2"
    And I am logged in as "kassi_testperson1"
    When I follow "Messages"
    And I follow "Sent"
    Then I should see "Ok"
    And I should see "Favor offer: Massage" within "h3"
    And I should not see "Another test"
    And I should not see "Test1"
    And I should see "Test2"
    And I should see "Item request: Hammer" within "h3"
    And I should see "Rideshare request: Helsinki - Turku" within "h3"
    And I should see "Test3"
  
  @javascript
  Scenario: Trying to view inbox without logging in
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And I am not logged in
    When I try to go to inbox of "kassi_testperson1"
    Then I should see "You must log in to Kassi to view your inbox." within "#notifications"
    And I should see "Log in to Kassi" within "h2"
  
  @javascript
  Scenario: Trying to view somebody else's inbox
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    When I try to go to inbox of "kassi_testperson1"
    Then I should see "You are not authorized to view this content" within "#notifications"
  
  @javascript
  Scenario: Trying to view somebody else's single conversation
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
      | kassi_testperson3 |
    And there is favor request with title "Massage" from "kassi_testperson2"
    And there is a message "Reply to massage" from "kassi_testperson3" about that listing
    And I am logged in as "kassi_testperson1"
    When I go to the conversation path of "kassi_testperson1"
    Then I should see "You are not authorized to view this content" within "#notifications"  