Feature: Admin edits info pages
  In order to have custom detail texts tailored specifically for my community
  As an admin
  I want to be able to edit the community details

  @javascript
  Scenario: Admin user can edit community details
    Given I am logged in as "kassi_testperson1"
    When I go to the admin view of community "test"
    And I follow "Edit information"
    And I change the contents of "name" to "Custom name"
    And I change the contents of "slogan" to "Custom slogan"
    And I change the contents of "description" to "This is a custom description"
    And I change the contents of "signup_info_content" to "Custom signup info"
    And I click save on the editor
    And I refresh the page
    Then I should see "Custom name"
    And I should see "Custom slogan"
    And I should see "This is a custom description"
    When I follow "view_slogan_link"
    Then I should see "Custom slogan"
    And I should see "This is a custom description"
    When I log out
    And I follow "log in"
    And I follow "Create a new account"
    Then I should see "Custom signup info"