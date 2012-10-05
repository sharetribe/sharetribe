Feature: User joins another community
  In order to be able to post listings simultaneously to multiple communities
  As a user
  I want to be able to join more than one Sharetribe community with my user account
  
  @javascript
  Scenario: User joins another community
    Given there are following users:
      | person | 
      | kassi_testperson3 |
    And I am on the home page
    And I move to community "test2"
    And I am on the home page
    And I log in as "kassi_testperson3"
    Then I should see "Join community"
    And I should not see "What others need"
    When I press "Join community"
    Then I should see "This field is required"
    When I check "community_membership_consent"
    And I press "Join community"
    Then I should see "You have successfully joined this community"
    And I should see "What others need"
  
  @javascript
  Scenario: User joins another community that is invitation-only
    Given there are following users:
      | person | 
      | kassi_testperson3 |
    And I am on the home page
    And I move to community "test2"
    And community "test2" requires invite to join
    And there is an invitation for community "test2" with code "GH1JX8"
    And I am on the home page
    And I am logged in as "kassi_testperson3"
    Then Invitation with code "GH1JX8" should have 1 usages_left
    And I should see "Invitation code:"
    When I check "community_membership_consent"
    And I fill in "Invitation code:" with "random"
    And I press "Join community"
    Then I should see "The invitation code is not valid."
    When I fill in "Invitation code:" with "GH1JX8"
    And I press "Join community"
    Then I should see "You have successfully joined this community"
    And I should see "What others need"
    And Invitation with code "GH1JX8" should have 0 usages_left
  
  @javascript
  Scenario: User joins another community that accepts only certain email addresses
    Given there are following users:
      | person | 
      | kassi_testperson3 |
    When I am logged in as "kassi_testperson3"
    And I move to community "test2"
    And this community requires users to have an email address of type "@gmail.com"
    Then I should see "Join community"
    And I should not see "What others need"
    And I should see "Email address:"
    When I check "community_membership_consent"
    And I press "Join community"
    Then I should see "This field is required."
    When I fill in "Email address:" with "random@email.com"
    And I press "Join community"
    Then I should see "This email is not allowed for this community or it is already in use."
    When I fill in "Email address:" with "random@gmail.com"
    And I press "Join community"
    Then I should see "Please confirm your email address"
    When I confirm the email "random@gmail.com"
    And I press "Join community"
    Then I should see "You have successfully joined this community"
  
  @javascript
  Scenario: User joins another community when having both visible and non-visible listings
    Given there are following users:
      | person | 
      | kassi_testperson3 |
    And there is favor request with title "Massage" from "kassi_testperson3"
    And visibility of that listing is "this_community"
    And there is favor request with title "Sewing" from "kassi_testperson3"
    And visibility of that listing is "all_communities"
    And I log in as "kassi_testperson3"
    And I am on the home page
    And I should see "Massage"
    And I should see "Sewing"
    And I move to community "test2"
    And I am on the home page
    Then I should see "Join community"
    And I should not see "What others need"
    When I press "Join community"
    Then I should see "This field is required"
    When I check "community_membership_consent"
    And I press "Join community"
    Then I should see "You have successfully joined this community"
    When the system processes jobs
    And I am on the home page
    And I should see "Sewing"
    And I should not see "Massage"