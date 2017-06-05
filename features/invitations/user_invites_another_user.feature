Feature: User joins invite only community
  In order to get critical mass to Sharetribe
  As a user in a community
  I want to invite my friend in this Sharetribe community

  Background:
    Given there are following users:
      | person |
      | kassi_testperson2 |
      | kassi_testperson1 |

  @javascript
  Scenario: User can access invite page from menu
    And I am logged in as "kassi_testperson1"
    When I navigate to invitations page
    Then I should be on invitations page

  @javascript
  Scenario: User invites another user successfully
    When users can not invite new users to join community "test"
    And I am on the homepage
    And I should not see "Invite friends"
    When I log in as "kassi_testperson2"
    And I am on invitations page
    And I should see "Post a new listing"
    Then I should not see "Invite your friends"
    When users can invite new users to join community "test"
    And I am on invitations page
    Then I should see "Email address(es)"
    And I fill in "invitation_email" with "test@example.com"
    And I fill in "invitation_message" with "test"
    And I press "Send invitation"
    And I dismiss the onboarding wizard
    Then I should see "Invitation sent successfully"
    When the system processes jobs
    And "test@example.com" should receive an email

    When I fill in "invitation_email" with "test@example.com"
    And I press "Send invitation"
    Then I should see "Invitation sent successfully"
    When the system processes jobs
    And "test@example.com" should receive 2 emails

    When I fill in "invitation_email" with "test2@example.com, another.test@example.com,third.strange.guy@example.com"
    And I fill in "invitation_message" with "test"
    And I press "Send invitation"
    Then I should see "Invitation sent successfully"

    When the system processes jobs
    And "test2@example.com" should receive an email
    And "another.test@example.com" should receive an email
    And "third.strange.guy@example.com" should receive an email

  @javascript
  Scenario: User tries to invite another user with invalid email address
    And I am logged in as "kassi_testperson1"
    And I am on invitations page
    And users can invite new users to join community "test"
    And I press "Send invitation"
    Then I should see "This field is required."
    When I fill in "invitation_email" with "test"
    And I press "Send invitation"
    Then I should see "Check that the email addresses you added are valid and don't contain any unusual characters."

