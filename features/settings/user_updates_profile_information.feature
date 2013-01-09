Feature: User updates profile information
  In order to change the information the other users see in my profile page
  As a user
  I want to able to update my profile information

  @javascript
  Scenario: Updating profile successfully
    Given there are following users:
      | person | 
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    When I click ".user-menu-toggle"
    When I follow "Settings"
    And I fill in "Given name" with "Test"
    And I fill in "Family name" with "Dude"
    And I fill in "Location" with "Broadway"
    And wait for 2 seconds
    # These features removed with google map functionality
    #And I fill in "Postal code" with "11111"
    #And I fill in "City" with "Turku"
    And I fill in "Phone number" with "0700-715517"
    And I fill in "About you" with "Some random text about me"
    And I press "Save information"
    Then I should see "Information updated" within ".flash-notifications"
    And the "Given name" field should contain "Test"
    And the "Family name" field should contain "Dude"
    And the "Location" field should contain "Broadway"
    And I should not see my username
  
  @javascript
  Scenario: Trying to update profile with false information
    Given there are following users:
      | person | 
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    And I can choose whether I want to show my username to others in community "test"
    When I click ".user-menu-toggle"
    When I follow "Settings"
    And I fill in "Given name" with "Testijeppe"
    And I uncheck "person_show_real_name_to_other_users"
    And I press "Save information"
    Then I should see "kassi_testperson2"
    And I should not see "Testijeppe"
    When I check "person_show_real_name_to_other_users"
    And I press "Save information"
    Then I should not see "kassi_testperson2"
    And I should see "Testijeppe"