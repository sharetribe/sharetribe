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
    When I go to the big cover photo home page
    Then I should see "Custom slogan"
    And I should see "This is a custom description"

  Scenario: Admin user can hide community slogan or description
    When I go to the admin view of community "test"
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

    When I go to the admin view of community "test"
    And I check "Display the slogan in the homepage"
    And I check "Display the description in the homepage"
    And I press submit
    When I go to the big cover photo home page
    Then I should see "Custom slogan"
    And I should see "This is a custom description"

    When I go to the admin view of community "test"
    And I check "Display the slogan in the homepage"
    And I uncheck "Display the description in the homepage"
    And I press submit
    When I go to the big cover photo home page
    Then I should see "Custom slogan"
    And I should not see "This is a custom description"

    When I go to the admin view of community "test"
    And I uncheck "Display the slogan in the homepage"
    And I check "Display the description in the homepage"
    And I press submit
    When I go to the big cover photo home page
    Then I should not see "Custom slogan"
    And I should see "This is a custom description"

  Scenario: Admin user can edit community details transaction agreement
    Given this community has transaction agreement in use
    When I go to the admin view of community "test"
    And I fill in "community_customizations[en][transaction_agreement_label]" with "This is a label"
    And I fill in "community_customizations[en][transaction_agreement_content]" with "This is a content"
    And I press submit
    Then I should see "This is a label" in the "community_customizations[en][transaction_agreement_label]" input
    Then I should see "This is a content" in the "community_customizations[en][transaction_agreement_content]" input
    When I fill in "community_customizations[en][transaction_agreement_label]" with "300" count of symbols
    And I press submit
    Then I should see "255" count of symbols in the "community_customizations[en][transaction_agreement_label]" input

  Scenario: Admin users can edit location search modes
    Given this community has location search enabled
    When I go to the admin settings view of community "test"
    Then I should see "Search and location preferences"
    When I select "Keyword" from "main_search"
    Then I should not see "Show distance"
    And I should not see "Show only nearby listings"
    When I select "Location" from "main_search"
    Then I should see "Show distance"
    And I should see "Show only nearby listings"
    Given this community has location search disabled
