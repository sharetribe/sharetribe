Feature: User updates profile information
  In order to change the information the other users see in my profile page
  As a user
  I want to able to update my profile information

  Background:
    Given there are following users:
      | person |
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    And I am on the profile settings page

  @javascript
  Scenario: Updating profile successfully
    When I fill in "First name" with "Test"
    And I fill in "Last name" with "Dude"
    And I fill in "Location" with "Broadway"
    And wait for 2 seconds
    And I fill in "Phone number" with "0700-715517"
    And I fill in "About you" with "Some random text about me"
    And I press "Save information"
    Then I should see "Information updated" within ".flash-notifications"
    And the "First name" field should contain "Test"
    And the "Last name" field should contain "Dude"
    And the "Location" field should contain "Broadway"
    And I should not see my username

  @skip_phantomjs
  @javascript
  Scenario: Updating profile avatar
    When I attach a valid image file to "avatar_file"
    And I press "Save information"
    Then I should see "Information updated" within ".flash-notifications"
    And I should not see my username
    And I should see the image I just uploaded