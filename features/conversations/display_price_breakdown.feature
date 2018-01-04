@javascript
Feature: User make transaction
  User make contact

  Background:
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |

  Scenario: "Price breakdown is visible. Conversation started on Buy button.
      Transaction with online payment system disabled and price enabled."
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    Then I should see price box on top of the message list

  Scenario: "Price breakdown is not visible. Conversation started on Contact button.
      Transaction with online payment system disabled and price enabled."
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And I am logged in as "kassi_testperson2"
    And I am on the home page
    When I follow "Massage"
    Then I should see "Massage"
    When I follow "Contact"
    When I fill in "listing_conversation_content" with "How are You."
    When I press "Send message"
    Then I should not see price box on top of the message list

  Scenario: "Price breakdown is not visible. Conversation started on Buy button.
      Transaction with online payment system disabled and price disabled."
    And there is a listing with title "Massage" from "kassi_testperson1" with category "Services" and with listing shape "Requesting"
    And that listing is free
    And there is a message "Test message" from "kassi_testperson2" about that listing
    And I am logged in as "kassi_testperson1"
    Then I should not see price box on top of the message list


