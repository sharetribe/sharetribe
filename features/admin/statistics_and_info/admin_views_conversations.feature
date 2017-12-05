@javascript
Feature: Admin views conversations
In order to analyze and improve my community
As an admin
I want to see see all the conversations happening in my community

  Background:
     Given there are following users:
      | person            | given_name | family_name | email               | membership_created_at     |
      | manager           | matti      | manager     | manager@example.com | 2014-03-01 00:12:35 +0200 |
      | kassi_testperson1 | john       | doe         | test2@example.com   | 2013-03-01 00:12:35 +0200 |
      | kassi_testperson2 | jane       | doe         | test1@example.com   | 2012-03-01 00:00:00 +0200 |
    And there is a listing with title "listing1" from "kassi_testperson1"

  Scenario: Admin views conversations started from user's profile
    When I am logged in as "kassi_testperson2"
    And I go to the profile page of "kassi_testperson1"
    And I follow "Contact"
    And I fill in "conversation[message_attributes][content]" with "contacted from listing"
    And I press submit
    When I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And I am on the conversations admin page
    Then I should see a conversation started from "john d's Profile" with status "Conversation"

  Scenario: Admin views conversations started from a listing
    When I am logged in as "kassi_testperson2"
    And I go to the listing page
    And I follow "Contact"
    And I fill in "listing_conversation[content]" with "contacted from listing"
    And I press submit
    When I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And I am on the conversations admin page
    Then I should see a conversation started from "listing1" with status "Conversation"
