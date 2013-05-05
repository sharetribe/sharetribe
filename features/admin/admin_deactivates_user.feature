Feature: Admin deactivates user
  
  @wip
  @javascript
  Scenario: Admin deactivates and reactivates a user
    Given USER DEACTIVATION IS NOT YET IN USE SO THIS TEST IS UNDEFINED NOW
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item offer with title "sledgehammer" from "kassi_testperson1" and with share type "sell"
    And I am logged in as "kassi_testperson1"
    And I am on the home page
    When I click ".user-menu-toggle"
    When I follow "Profile"
    And I should not see "This user is no longer active in Sharetribe"
    And I should see "sledgehammer"
    When I follow "Deactivate"
    Then I should see "This user is no longer active in Sharetribe"
    And I should see "User deactivated"
    When I click ".user-menu-toggle"
    When I follow "Profile"
    Then I should not see "sledgehammer"
    When I follow "Activate"
    Then I should not see "This user is no longer active in Sharetribe"
    And I should see "User activated"
    
  @wip
  @javascript
  Scenario: User reactivates himself by logging in
    Given USER DEACTIVATION IS NOT YET IN USE SO THIS TEST IS UNDEFINED NOW
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item offer with title "sledgehammer" from "kassi_testperson1" and with share type "sell"
    And I am logged in as "kassi_testperson1"
    And I am on the home page
    When I click ".user-menu-toggle"
    When I follow "Profile"
    And I should not see "This user is no longer active in Sharetribe"
    And I should see "sledgehammer"
    When I follow "Deactivate"
    Then I should see "This user is no longer active in Sharetribe"
    And I should not see "Deactivate"
    And I click ".user-menu-toggle"
    When I follow "Logout"
    And I log in as "kassi_testperson1"
    And I follow "profile"
    Then I should not see "This user is no longer active in Sharetribe"
    And I should see "Deactivate"
  
  Scenario: A person who is not admin tries to deactivate a user
    Given I am logged in as "kassi_testperson2"
    And I am on the home page
    When I click ".user-menu-toggle"
    When I follow "Profile"
    Then I should not see "Deactivate"
  
  
  

  
  
