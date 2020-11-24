Feature: User follows another user

  Background:
    Given there are following users:
       | person            | given_name |
       | kassi_testperson1 | Me         |
       | kassi_testperson2 | Them       |
    And I am logged in as "kassi_testperson1"            

  @javascript
  Scenario: User follows another user
    When I go to the profile page of "kassi_testperson2"
    And I follow "Follow"
    Then I should see "Following" within ".profile-action-buttons-desktop"
    When I go to my profile page
    Then I should see "Them" within "#profile-followed-people-list"

  @javascript
  Scenario: User unfollows another user
    Given "kassi_testperson1" follows "kassi_testperson2"
    When I go to the profile page of "kassi_testperson2"
    And I follow "Unfollow"
    Then I should see "Follow" within ".profile-action-buttons-desktop"
    And I should not see "Following" within ".profile-action-buttons-desktop"
    When I go to my profile page
    Then I should see "No followed people"

  @javascript
  Scenario: User views additional followed people
    Given there are 10 users with name prefix "User" "Number"
    And "kassi_testperson1" follows everyone
    When I go to the profile page of "kassi_testperson1"
    Then I should see "You follow 11 people"
    
    When I follow "Show all followed people"
    Then I should not see "Show all followed people"
    Then I should see 11 user profile links

    When I follow the first "Following"
    And I refresh the page
    Then I should see "You follow 10 people"

  @javascript
  Scenario: Follower receives notification of new listing
    Given "kassi_testperson2" follows "kassi_testperson1"
    When I create a new listing "Jewelry" with price "899"
    And the system moves all future jobs to immediate
    And the system processes jobs
    Then "kassi_testperson2@example.com" should receive an email
    When I open the email
    Then I should see "Jewelry" in the email body

