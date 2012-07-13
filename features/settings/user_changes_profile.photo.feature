Feature: User changes profile photo
  In order to show other users what I look like
  As a user
  I want to be able to upload a profile photo

  @javascript
  Scenario: title
    Given I am logged in as "kassi_testperson1"
    And I am on the home page
    When I follow "Settings"
    And I follow "Profile picture"
    And I attach a valid image file to "avatar_file"
    And I press "Save picture"
    Then I should see "Avatar upload successful" within "#notifications"
    And I should see the image I just uploaded