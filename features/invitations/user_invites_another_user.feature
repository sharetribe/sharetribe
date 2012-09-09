Feature: User joins invite only community
  In order to get critical mass to Sharetribe
  As a user in a community
  I want to invite my friend in this Sharetribe community
  
  @javascript
  Scenario: User invites another user successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And I am on the homepage
    And I should not see "Your friend's email address"
    When I log in as "kassi_testperson2"
    Then I should not see "Your friend's email address"
    When users can invite new users to join community "test"
    And I am on the homepage
    Then I should see "Your friend's email address"
    And I fill in "invitation_email" with "test@example.com"
    And I fill in "invitation_message" with "test"
    And I press "Send invitation"
    Then I should see "Invitation sent successfully" within "#notifications"
    # Make sure that sending multiple invitations in a row works
    # (this had problems before)
    When I fill in "invitation_email" with "test@example.com"
    And I fill in "invitation_message" with "test"
    And I press "Send invitation"
  
  @javascript
  Scenario: User tries to invite another user with invalid email address
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And I am on the homepage
    And I am logged in as "kassi_testperson1"
    And users can invite new users to join community "test"
    And I press "Send invitation"
    Then I should see "This field is required." 
    When I fill in "invitation_email" with "test"
    Then I should see "Please enter a valid email address."
  
  