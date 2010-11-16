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
    When I follow "Settings"
    And I fill in "Given name*:" with "Test"
    And I fill in "Family name*:" with "Dude"
    And I fill in "Street address" with "Test Street 1"
    And I fill in "Postal code" with "11111"
    And I fill in "City" with "Turku"
    And I fill in "Phone number" with "0700-715517"
    And I fill in "About you:" with "Some random text about me"
    And I press "Save information"
    Then I should see "Information updated" within "#notifications"
    And the "Given name*:" field should contain "Test"
  
  @javascript
  Scenario: Trying to update profile with false information
    Given there are following users:
      | person | 
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    When I follow "Settings"
    And I fill in "Given name*:" with "T"
    And I fill in "Family name*:" with ""
    And I press "Save information"
    Then I should see "This field is required." within ".error"
    And I should see "Please enter at least 2 characters." within ".error"
  

