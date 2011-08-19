Feature: Admin deactivates user
  
  @javascript
  Scenario: Admin deactivates and reactivates a user
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item offer with title "sledgehammer" from "kassi_testperson1" and with share type "sell"
    And I am logged in as "kassi_testperson1"
    And I am on the home page
    When I follow "profile"
    And I should not see "This user is no longer active in Kassi"
    And I should see "sledgehammer"
    When I follow "Deactivate"
    Then I should see "This user is no longer active in Kassi"
    And I should see "User deactivated"
    When I follow "profile"
    Then I should not see "sledgehammer"
    When I follow "Activate"
    Then I should not see "This user is no longer active in Kassi"
    And I should see "User activated"

  @javascript
  Scenario: User reactivates himself by logging in
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there is item offer with title "sledgehammer" from "kassi_testperson1" and with share type "sell"
    And I am logged in as "kassi_testperson1"
    And I am on the home page
    When I follow "profile"
    And I should not see "This user is no longer active in Kassi"
    And I should see "sledgehammer"
    When I follow "Deactivate"
    Then I should see "This user is no longer active in Kassi"
    And I should not see "Deactivate"
    When I follow "Logout"
    And I am logged in as "kassi_testperson1"
    And I follow "profile"
    Then I should not see "This user is no longer active in Kassi"
    And I should see "Deactivate"
  
  Scenario: A person who is not admin tries to deactivate a user
    Given I am logged in as "kassi_testperson2"
    And I am on the home page
    When I follow "profile"
    Then I should not see "Deactivate"
  
  
  

  
  
