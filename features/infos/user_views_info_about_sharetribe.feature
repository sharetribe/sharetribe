Feature: User views info about sharetribe
  In order to find information about the service
  As a new user
  I want to be able to read about the community

  @javascript
  Scenario: User can browse to about page
    Given I am on the home page
    And I open the menu
    And I follow "About" within the menu
    Then I should see "This marketplace is powered by Sharetribe platform." within ".about-section"
    And I should see "About" within ".left-navi"
    And I should see "About" within ".selected.left-navi-link"
    And I should see "Terms of use"
    And I should see "Privacy"

  @javascript
  Scenario: User views terms page
    Given I am on the home page
    And I open the menu
    And I follow "About" within the menu
    And I follow "Terms of use" within ".left-navi"
    And I should see "About" within ".left-navi"
    And I should not see "About" within ".selected.left-navi-link"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".left-navi"
    And I should see "Rights of Content"

  @javascript
  Scenario: User views register details page
    Given I am on the home page
    And I open the menu
    And I follow "About" within the menu
    And I follow "Privacy" within ".left-navi"
    And I should see "About" within ".left-navi"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".selected.left-navi-link"
    And I should see "Name of the register"
