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
      | Title    | Initiated by | Listing author | Started                   | Last activity             | Amount | Status  |
      | Hey man! | john doe     | jane doe       | 2014-03-01 00:12:35 +0200 | 2014-03-01 00:12:35 +0200 |        | Free    |
      | Saw      | jane doe     | john doe       | 2013-03-01 00:12:35 +0200 | 2014-03-01 00:12:35 +0200 | 20$    | Pending |
      | Drill    | john doe     | jane doe       | 2014-03-01 00:12:35 +0200 | 2014-03-01 00:12:35 +0200 | 25$    | Paid    |
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And I am on the transactions admin page

  Scenario: Admin views all transactions
    Then I should see 1 transaction with status "Free"
    And I should see 1 transaction with status "Pending"
    And I should see 1 transaction with status "Paid"

  Scenario: Admin sorts transactions

  Scenario: Admin follows link to conversation


