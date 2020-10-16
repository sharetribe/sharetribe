@javascript
Feature: Admin edits general privacy page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit privacy settings
    When I go to the admin2 general privacy community "test"
    And I check "Make marketplace private (allow only registered users to see listings and user profiles)"

    When I follow "Open in editor"
    And I change the contents of "private_community_homepage_content" to "Home Page Content"
    And I click save on the editor

    When I go to the big cover photo home page
    Then I should see "Home Page Content"
