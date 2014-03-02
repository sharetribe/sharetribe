Feature: Admin lists members
  
  Background:
    Given there are following users: 
      | person            | given_name | family_name | email               | membership_created_at     | 
      | manager           | matti      | manager     | manager@example.com | 2014-03-01 00:12:35 +0200 |
      | kassi_testperson1 | john       | doe         | test1@example.com   | 2013-03-01 00:12:35 +0200 |
      | kassi_testperson2 | jane       | doe         | test2@example.com   | 2012-03-01 00:00:00 +0200 |
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And "kassi_testperson1" has admin rights in community "test"
    And I am on the manage members admin page

  @javascript
  Scenario: Admin views list of members
    Then I should see list of users with the following details:
      | Name          | Email               | Join date  | Posting allowed | Remove User | 
      | matti manager | manager@example.com | 2014-03-01 |                 |             |
      | john doe      | test1@example.com   | 2013-03-01 |                 |             |
      | jane doe      | test2@example.com   | 2012-03-01 |                 |             |

  @javascript
  Scenario: Admin views member count
    Given there are 50 users with name prefix "User" "Number"
    And I go to the manage members admin page
    Then I should see a range from 1 to 50 with total user count of 53

  @javascript
  Scenario: Admin views multiple users with pagination
    Given there are 50 users with name prefix "User" "Number"
    And I go to the manage members admin page
    Then I should see 50 users
    And the first user should be "User Number 50"
    When I follow "Next"
    Then I should see 3 users
    And the first user should be "matti manager"

  @javascript
  Scenario: Admin verifies sellers
    Given only verified users can post listings in this community
    And I refresh the page
    Then I should see that "john doe" cannot post new listings
    When I verify user "john doe" as a seller
    Then I should see that "john doe" can post new listings
    When I refresh the page
    Then I should see that "john doe" can post new listings

  @javascript
  Scenario: Admin removes a user
    When I remove user "john doe"
    And  I confirm alert popup
    Then I should not see "john doe"
    And "john doe" should be banned from this community

  @javascript
  Scenario: Admin promotes user to admin
    Then I should see that "manager" has admin rights in this community
    Then I should see that "john doe" has admin rights in this community
    Then I should see that "jane doe" does not have admin rights in this community
    When I promote "jane doe" to admin
    Then I should see that "jane doe" has admin rights in this community
    When I refresh the page
    Then I should see that "jane doe" has admin rights in this community

  @javascript
  Scenario: Admin is not able to remove her own admin rights
    Then I should see that "jane doe" does not have admin rights in this community
    And I should see that I can remove admin rights of "jane doe"
    Then I should see that "manager" has admin rights in this community
    And I should see that I can not remove admin rights of "manager"
