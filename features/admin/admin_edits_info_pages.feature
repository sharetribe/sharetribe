Feature: Admin edits info pages
  In order to give my users information specific to my community
  As an admin
  I want to be able to edit the info pages

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
    Then I should not have editor open
    Then I should see "This is a new line to about text"
    When I refresh the page
    Then I should see "This is a new line to about text"

  @javascript
  Scenario: Admin user can edit terms page
    Given I am logged in as "kassi_testperson1"
    And I am on the terms page
    Then I should not have editor open
    When I go to the terms page
    And I follow "Edit page"
    Then I should have editor open
    When I send keys "This is a new line to terms text" to editor
    And I click save on the editor
    Then I should not have editor open
    Then I should see "This is a new line to terms text"
    When I refresh the page
    Then I should see "This is a new line to terms text"

  @javascript
  Scenario: Admin user can edit privacy policy page
    Given I am logged in as "kassi_testperson1"
    And I am on the privacy policy page
    Then I should not have editor open
    When I go to the privacy policy page
    And I follow "Edit page"
    Then I should have editor open
    When I send keys "This is a new line to privacy policy text" to editor
    And I click save on the editor
    Then I should not have editor open
    Then I should see "This is a new line to privacy policy text"
    When I refresh the page
    Then I should see "This is a new line to privacy policy text"