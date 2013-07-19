Feature: User views info about sharetribe
  In order to find information about the service
  As a new user
  I want to be able to read about the community

  @javascript
  Scenario: User views about page
    Given I am on the home page
    When I follow "About"
    Then I should see "This website was created using the Sharetribe platform." within ".about-section"
    And I should see "About" within ".left-navi"
    And I should see "About" within ".selected.left-navi-link"
    And I should see "Terms of use"
    And I should see "Privacy"
    When I log in as "kassi_testperson2"
    And I follow "About"
    Then I should not see "Edit page"
    When I log out
    And I log in as "kassi_testperson1"
    And I follow "About"
    Then I should not see "Save"
    When I follow "Edit page"
    Then I should see "Save"
  
  @javascript
  Scenario: User views terms page
    Given I am on the home page
    When I follow "About"
    And I follow "Terms of use" within ".left-navi"
    And I should see "About" within ".left-navi"
    And I should not see "About" within ".selected.left-navi-link"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".left-navi"
    And I should see "Rights of Content"
  
  @javascript
  Scenario: User views register details page
    Given I am on the home page
    When I follow "About"
    And I follow "Privacy" within ".left-navi"
    And I should see "About" within ".left-navi"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".selected.left-navi-link"
    And I should see "Name of the register"
