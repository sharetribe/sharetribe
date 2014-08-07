@javascript
Feature: Admin views transactions
In order to analyze and improve my community
As an admin
I want to see see all the transactions happening in my community

  Background:
     Given there are following users:
      | person            | given_name | family_name | email               | membership_created_at     |
      | manager           | matti      | manager     | manager@example.com | 2014-03-01 00:12:35 +0200 |
      | kassi_testperson1 | john       | doe         | test2@example.com   | 2013-03-01 00:12:35 +0200 |
      | kassi_testperson2 | jane       | doe         | test1@example.com   | 2012-03-01 00:00:00 +0200 |
    And there are following transactions
      | conversation_thread                    | listing     | status  | sum | currency | started_at  | latest_activity | starter           | other_party       |
      | Hi! Could you help me...               | Moving help | pending | 127 | EUR      | 2 days ago  | 3 hours ago     | kassi_testperson1 | kassi_testperson2 |
      | I want 2 kg of...                      | Red apples  | paid    | 60  | USD      | 1 week ago  | 2 hours ago     | kassi_testperson2 | kassi_testperson1 |
      | This is a free message from listing... | Power drill | free    |     |          | 2 hours ago | 1 hour ago      | kassi_testperson1 | kassi_testperson2 |
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And I am on the transactions admin page

  Scenario: Admin views all transactions
    Then I should see 1 transaction with status "Free conversation"
    And I should see 1 transaction with status "Pending"
    And I should see 1 transaction with status "Paid"

  Scenario: Admin sorts transactions by listing
    When I sort by "listing"
    Then I should see the transactions in ascending order by "listing"
    When I sort by "listing"
    Then I should see the transactions in descending order by "listing"

  Scenario: Admin sorts transactions by sum

  Scenario: Admin sorts transactions by start date

  Scenario: Admin sorts transactions by latest activity

  Scenario: Admin sorts transactions by starter

  Scenario: Admin sorts transactions by other party

  Scenario: Admin follows link to conversation


