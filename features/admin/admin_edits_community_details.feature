@javascript
Feature: Admin edits info pages
  In order to have custom detail texts tailored specifically for my community
  As an admin
  I want to be able to edit the community details

  Background:
    Given "kassi_testperson1" has admin rights in community "test"
    And I am logged in as "kassi_testperson1"

  Scenario: Admin user can edit community details
    When I go to the admin view of community "test"

    And I fill in "community_customizations[en][name]" with "Custom name"
    And I fill in "community_customizations[en][slogan]" with "Custom slogan"
    And I fill in "community_customizations[en][description]" with "This is a custom description"
    And I press submit
    When I follow "view_slogan_link"
    Then I should see "Custom slogan"
    And I should see "This is a custom description"