Feature: User joins another community
  In order to be able to post listings simultaneously to multiple communities
  As a user
  I want to be able to join more than one Kassi community with my user account
  
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
    When I check "community_membership_terms"
    And I press "Join community"
    Then I should see "You have successfully joined this community"
    And I should see "What others need"
  
  @javascript
  Scenario: User joins another community that is invitation-only
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    When I am logged in as "kassi_testperson1"
    And I move to community "test2"
    Then I should see "Join community"
    And I should not see "What others need"
    When I check "community_membership_terms"
    And I press "Join community"
    Then I should see "You have successfully joined this community"
    And I should see "What others need"
  
  @javascript
  Scenario: User joins another community that requires email confirmation
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    When I am logged in as "kassi_testperson1"
    And I move to community "test2"
    Then I should see "Join community"
    And I should not see "What others need"
    When I check "community_membership_terms"
    And I press "Join community"
    Then I should see "You have successfully joined this community"
  
  @javascript
  Scenario: User adds a listing and sees it in another community
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item request with title "Hammer" from "kassi_testperson1" and with share type "buy"
    And I am on the homepage
    Then I should see "Hammer"
    When I move to community "test2"
    And I am on the homepage
    Then I should not see "Hammer"
    When "kassi_testperson1" joins community "test2"
    And the system processes jobs


