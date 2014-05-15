Feature: User changes password
  In order to change my password Sharetribe
  As a user
  I want to be able to change my password

  @javascript
  Scenario: Changing email address successfully
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I open user menu
    When I follow "Settings"
    And I follow "Account" within ".left-navi"
    And I follow "account_password_link"
    And I fill in "person_password" with "testi"
    And I fill in "person_password2" with "testi"
    And I press "password_submit"
    Then I should see "Information updated" within ".flash-notifications"

  @javascript
  Scenario: Changing email address successfully
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I open user menu
    When I follow "Settings"
    And I follow "Account" within ".left-navi"
    And I follow "account_password_link"
    And I fill in "person_password" with "testi"
    And I fill in "person_password2" with "testing"
    And I press "password_submit"
    Then I should see "Please enter the same value again."
