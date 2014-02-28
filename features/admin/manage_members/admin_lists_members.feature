Feature: Admin lists members
  
  Background:
    Given there are following users: 
      | person            | given_name | family_name | email               | created_at                | 
      | manager           | matti      | manager     | manager@example.com | 2014-03-01 00:12:35 +0200 |
      | kassi_testperson1 | john       | doe         | test1@example.com   | 2013-03-01 00:12:35 +0200 |
      | kassi_testperson2 | jane       | doe         | test2@example.com   | 2012-03-01 00:00:00 +0200 |
    And I am logged in as "manager"
    And "manager" has admin rights in community "test"
    And I am on the manage members admin page

  @javascript
  Scenario: Admin views list of members
    Then I should see list of users with the following details:
      | Name          | Email               | Join date  |
      | matti manager | manager@example.com | 2014-03-01 |
      | john doe      | test1@example.com   | 2013-03-01 | 
      | jane doe      | test2@example.com   | 2012-03-01 |

  @javascript
  Scenario: Admin views member count
    Then I should see member count 3
