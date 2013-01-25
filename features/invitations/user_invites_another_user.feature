Feature: User joins invite only community
  In order to get critical mass to Sharetribe
  As a user in a community
  I want to invite my friend in this Sharetribe community
  
  Scenario: User invites another user successfully
    Given there are following users:
      | person | 
      | kassi_testperson2 |
    And I am on the homepage
    And I should not see "Invite friends"
    When I log in as "kassi_testperson2"
    And I am on invitations page
    Then I should not see "Invite your friends"
    # I Should be redirected to front page
    And I should see "Post a new listing"
    When users can invite new users to join community "test"
    And I am on invitations page
    Then I should see "Email address(es)"
    And I fill in "invitation_email" with "test@example.com"
    And I fill in "invitation_message" with "test"
    And I press "Send invitation"
    Then I should see "Invitation sent successfully" 
    When I fill in "invitation_email" with "test@example.com"
    And I press "Send invitation"
    Then I should see "Invitation sent successfully" 
    When I fill in "invitation_email" with "test@example.com, another.test@example.com,third.strange.guy@example.com"
    And I fill in "invitation_message" with "test"
    And I press "Send invitation"
    Then I should see "Invitation sent successfully" 
    
  @javascript
  Scenario: User tries to invite another user with invalid email address
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    And I am on invitations page
    And users can invite new users to join community "test"
    And I press "Send invitation"
    Then I should see "This field is required." 
    When I fill in "invitation_email" with "test"
    Then I should see "Check that there are valid emails"
  
  