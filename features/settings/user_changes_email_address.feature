Feature: User changes email address
  In order to change the email address associated with me in Sharetribe
  As a user
  I want to be able to change my email address
  
  # @javascript
  # Scenario: Changing email address successfully
  #   Given there are following users:
  #     | person | 
  #     | kassi_testperson1 |
  #   And I am logged in as "kassi_testperson1"
  #   When I click ".user-menu-toggle"
  #   When I follow "Settings"
  #   And I follow "Account" within ".left-navi"
  #   And I follow "account_email_link"
  #   And I fill in "person_email" with random email
  #   And wait for 1 seconds
  #   And I press "email_submit"
  #   Then I should see "Information updated" within ".flash-notifications"
  #   And I should see the email I gave within "#account_email_content"
    
    
  # @javascript
  # Scenario: Trying to update email address with false information
  #   Given there are following users:
  #     | person | 
  #     | kassi_testperson1 |
  #   And I am logged in as "kassi_testperson1"
  #   When I click ".user-menu-toggle"
  #   When I follow "Settings"
  #   And I follow "Account" within ".left-navi"
  #   And I follow "account_email_link"
  #   And I fill in "person_email" with "this is not email"
  #   And I press "email_submit"
  #   Then I should not see "Information updated"
  #   And I should see "Please enter a valid email address." 
  
  Background:
    Given there are following users:
      | person            |
      | kassi_testperson1 |
    And there are following emails:
      | person            | address            | send_notifications |
      | kassi_testperson1 | kassi@example.com  | false              |
      | kassi_testperson1 | kassi2@example.com | true               |
      | kassi_testperson1 | kassi@gmail.com    | false              |
    And there are following communities:
      | community               | allowed_emails |
      | test_community          | @example.com   |
      | another_test_community  | @gmail.com     |
    And "kassi_testperson1" is a member of community "test_community"
    And "kassi_testperson1" is a member of community "another_test_community"
    And I am logged in as "kassi_testperson1"
    And I am on the account settings page

  @javascript
  Scenario: User adds a new email (and confirms it)
    When I add a new email "kassi_testperson1-2@example.com"
    Then I should have unconfirmed email "kassi_testperson1-2@example.com"
    When I confirm email address "kassi_testperson1-2@example.com"
    Then I should have confirmed email "kassi_testperson1-2@example.com"

  @javascript
  Scenario: User removes an email
    Then I should not be able to remove email "kassi@example.com"
    Then I should not be able to remove email "kassi@gmail.com"
    When I remove "kassi@example.com"
    Then I should not have email "kassi@example.com"

  @javascript
  Scenario: User changes notification email
    Then I should not be able to remove notifications from "kassi2@example.com"
    When I set notifications for email "kassi@example.com"
    Then I should be able to remove notifications from "kassi@example.com"
