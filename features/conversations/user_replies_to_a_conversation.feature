Feature: User replies to a conversation
  In order to reply to the sender of a message
  As a receiver of the message
  I want to be able to go to my inbox and reply to the message

  @javascript
  Scenario: Successful reply
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    And I follow "Test message"
    And I fill in "Write a reply:" with "This is a reply"
    And I press "Send reply"
    Then I should see "This is a reply"

  @javascript
  Scenario: Trying to reply without content
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with transaction type "Requesting"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    When I follow inbox link
    And I follow "Test message"
    And I press "Send reply"
    Then I should see "This field is required"

