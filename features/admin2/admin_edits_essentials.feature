@javascript
Feature: Admin edits info pages
  In order to have custom detail texts tailored specifically for my community
  As an admin
  I want to be able to edit the community details

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit community details
    When I go to the admin2 general essential community "test"

    And I fill in "community_customizations[en][name]" with "Custom name"
    And I fill in "community_customizations[en][slogan]" with "Custom slogan"
    And I fill in "community_customizations[en][description]" with "This is a custom description"
    And I press submit
    When I go to the big cover photo home page
    Then I should see "Custom slogan"
    And I should see "This is a custom description"

  Scenario: Admin user can hide community slogan or description
    When I go to the admin2 general essential community "test"
    And I should see "Display the slogan in the homepage"
    And I should see "Display the description in the homepage"
    And I uncheck "Display the slogan in the homepage"
    And I uncheck "Display the description in the homepage"
    And I fill in "community_customizations[en][slogan]" with "Custom slogan"
    And I fill in "community_customizations[en][description]" with "This is a custom description"
    And I press submit
    When I go to the big cover photo home page
    Then I should not see "Custom slogan"
    And I should not see "This is a custom description"

    When I go to the admin2 general essential community "test"
    And I check "Display the slogan in the homepage"
    And I check "Display the description in the homepage"
    And I press submit
    When I go to the big cover photo home page
    Then I should see "Custom slogan"
    And I should see "This is a custom description"

    When I go to the admin2 general essential community "test"
    And I check "Display the slogan in the homepage"
    And I uncheck "Display the description in the homepage"
    And I press submit
    When I go to the big cover photo home page
    Then I should see "Custom slogan"
    And I should not see "This is a custom description"

    When I go to the admin2 general essential community "test"
    And I uncheck "Display the slogan in the homepage"
    And I check "Display the description in the homepage"
    And I press submit
    When I go to the big cover photo home page
    Then I should not see "Custom slogan"
    And I should see "This is a custom description"
