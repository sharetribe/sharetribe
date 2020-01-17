@javascript
Feature: Admin edits general privacy page

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit privacy settings
    When I go to the admin2 general privacy community "test"
    And I check "Allow only registered users to see listings and user profiles (make marketplace private)"

    And I fill in "community_customizations[en][private_community_homepage_content]" with "Home Page Content"
    And I press submit
    When I go to the big cover photo home page
    Then I should see "Home Page Content"
