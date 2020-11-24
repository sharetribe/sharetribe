@javascript
Feature: Admin lists members

  Background:
    Given there are following users:
      | person            | given_name | family_name | email               | membership_created_at     | display_name |
      | manager           | matti      | manager     | manager@example.com | 2014-03-01 00:12:35 +0000 |              |
      | kassi_testperson1 | john       | doe         | test2@example.com   | 2013-03-01 00:12:35 +0000 |              |
      | kassi_testperson2 | jane       | doe         | test1@example.com   | 2012-03-01 00:00:00 +0000 | Puckett      |
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And "kassi_testperson1" has admin rights in community "test"
    And I am on the manage users admin2 page

  Scenario: Admin views & sorts list of members
    Then I should see list of users with the following details:
      | Name               | Email               | Joined      | Posting allowed | Remove User |
      | matti manager      | manager@example.com | Mar 1, 2014 |                 |             |
      | john doe           | test2@example.com   | Mar 1, 2013 |                 |             |
      | jane doe (Puckett) | test1@example.com   | Mar 1, 2012 |                 |             |
    When I follow "Name"
    Then I should see list of users with the following details:
      | Name               | Email               | Joined      | Posting allowed | Remove User |
      | jane doe (Puckett) | test1@example.com   | Mar 1, 2012 |                 |             |
      | john doe           | test2@example.com   | Mar 1, 2013 |                 |             |
      | matti manager      | manager@example.com | Mar 1, 2014 |                 |             |
    When I follow "Name"
    Then I should see list of users with the following details:
      | Name               | Email               | Joined      | Posting allowed | Remove User |
      | matti manager      | manager@example.com | Mar 1, 2014 |                 |             |
      | john doe           | test2@example.com   | Mar 1, 2013 |                 |             |
      | jane doe (Puckett) | test1@example.com   | Mar 1, 2012 |                 |             |
    When I follow "Email"
    Then I should see list of users with the following details:
      | Name               | Email               | Joined      | Posting allowed | Remove User |
      | matti manager      | manager@example.com | Mar 1, 2014 |                 |             |
      | jane doe (Puckett) | test1@example.com   | Mar 1, 2012 |                 |             |
      | john doe           | test2@example.com   | Mar 1, 2013 |                 |             |
    When I follow "Joined"
    Then I should see list of users with the following details:
      | Name               | Email               | Joined      | Posting allowed | Remove User |
      | jane doe (Puckett) | test1@example.com   | Mar 1, 2012 |                 |             |
      | john doe           | test2@example.com   | Mar 1, 2013 |                 |             |
      | matti manager      | manager@example.com | Mar 1, 2014 |                 |             |

  Scenario: Admin views member count
    Given there are 3 banned users with name prefix "Hazel" "Banned %d"
    Given there are 2 unconfirmed users with name prefix "Bertha" "Unconfirmed %d"
    Given there are 100 users with name prefix "User" "Number %d"
    And I go to the manage users admin2 page
    Then I should see a range from 1 to 100 with total 103 accepted and 5 other users
    And I fill in "q" with "Number 4"
    And I submit the form
    Then I should see "Displaying 11 accepted users and 0 other users"

  Scenario: Admin views multiple users with pagination
    Given there are 100 users with name prefix "User" "Number 100"
    And I go to the manage users admin2 page
    Then I should see 100 users
    And the first user should be "User Number 100"
    When I follow "Next"
    Then I should see 3 users
    And the first user should be "matti manager"

  Scenario: Admin verifies sellers
    Given only verified users can post listings in this community
    And I refresh the page
    Then I should see that "john doe" cannot post new listings
    When I verify user "john doe" as a seller
    Then I should see that "john doe" can post new listings
    When I refresh the page
    Then I should see that "john doe" can post new listings

  Scenario: Admin bans and unbans a user
    Given there is a listing with title "Sledgehammer" from "kassi_testperson1" with category "Items" and with listing shape "Requesting"
     When I am on the home page
     Then I should see "Sledgehammer"

    Given I am on the manage users admin2 page
      And I will confirm all following confirmation dialogs in this page if I am running PhantomJS
     When I ban user "john doe"
     Then I should see "john doe"
     Then I wait for 1 seconds
     # Identifying is easier when using username
     And "kassi_testperson1" should be banned from this community

    Given I am on the home page
     Then I should not see "Sledgehammer"

    Given I am on the manage users admin2 page
      And I will confirm all following confirmation dialogs in this page if I am running PhantomJS
     When I unban user "john doe"
     Then I should see "john doe"
     Then I wait for 1 seconds
     And "kassi_testperson1" should not be banned from this community

    Given I am on the home page
     Then I should not see "Sledgehammer"

  Scenario: Admin promotes user to admin
    Given I will confirm all following confirmation dialogs in this page if I am running PhantomJS
    Then I should see that "manager" has admin rights in this community
    Then I should see that "john doe" has admin rights in this community
    Then I should see that "jane doe" does not have admin rights in this community
    When I promote "jane doe" to admin
    Then I wait for 1 seconds
    Then I should see that "jane doe" has admin rights in this community
    When I refresh the page
    Then I should see that "jane doe" has admin rights in this community

  Scenario: Admin is not able to remove her own admin rights
    Then I should see that "jane doe" does not have admin rights in this community
    And I should see that I can remove admin rights of "jane doe"
    Then I should see that "manager" has admin rights in this community
    And I should see that I can not remove admin rights of "manager"

