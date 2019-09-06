Feature: User requests new password
  In order to retrieve a new password
  As a user who has forgotten his password
  I want to request a new password

  @javascript
  Scenario: User requests new password successfully
    Given I am on the home page
    When I follow log in link
    And I follow "Forgot password"
    And I fill in "Email" with "kassi_testperson2@example.com"
    And I press submit within "#password_forgotten"
    Then I should see "Instructions to change your password were sent to your email." within ".flash-notifications"
    And "kassi_testperson2@example.com" should receive an email with subject "Reset password instructions"

  @javascript
  Scenario: User requests new password with email that doesn't exist
    Given I am on the home page
    When I follow log in link
    And I follow "Forgot password"
    And I fill in "Email" with "some random string"
    And I press submit within "#password_forgotten"
    When I wait for 1 seconds
    Then I should see "The email you gave was not found from Sharetribe database." within ".flash-notifications"








