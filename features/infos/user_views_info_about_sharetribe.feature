Feature: User views info about sharetribe
  In order to find information about the service
  As a new user
  I want to be able to read about the community

  @javascript
  Scenario: User can browse to about page
    Given I am on the home page
    When I follow "global-navi-about"
    Then I should see "This marketplace is powered by Sharetribe platform." within ".about-section"
    And I should see "About" within ".left-navi"
    And I should see "About" within ".selected.left-navi-link"
    And I should see "Terms of use"
    And I should see "Privacy"

  @javascript
  Scenario: Normal user can not edit about page
    Given I am logged in as "kassi_testperson2"
    And I am on the about page
    Then I should not see "Edit page"

  @javascript
  Scenario: Admin user can edit about page
    Given I am logged in as "kassi_testperson1"
    And I am on the about page
    Then I should not have editor open
    When I follow "Edit page"
    Then I should have editor open
    When I send keys "This is a new line to about text" to editor
    And I click save on the editor
    And I refresh the page
    Then I should see "This is a new line to about text"
  
  @javascript
  Scenario: User views terms page
    Given I am on the home page
    When I follow "global-navi-about"
    And I follow "Terms of use" within ".left-navi"
    And I should see "About" within ".left-navi"
    And I should not see "About" within ".selected.left-navi-link"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".left-navi"
    And I should see "Rights of Content"
  
  @javascript
  Scenario: User views register details page
    Given I am on the home page
    When I follow "global-navi-about"
    And I follow "Privacy" within ".left-navi"
    And I should see "About" within ".left-navi"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".selected.left-navi-link"
    And I should see "Name of the register"
