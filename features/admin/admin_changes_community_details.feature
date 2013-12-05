Feature: Admin changes community details

  Background:
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And there are following communities:
      | community               | slogan                    | description                                          |
      | test_community          | Slogan for my marketplace | This is a place to sell, rent, swap and share goods |
    And "kassi_testperson1" is a member of community "test_community"
    And "kassi_testperson1" has admin rights in community "test_community"
    And I move to community "test_community"

  @javascript
  Scenario: Custom community slogan
    When I am on the homepage
    Then I should see slogan "Slogan for my marketplace"

  @javascript
  Scenario: Admin removes the slogan
    And I am logged in as "kassi_testperson1"
    And I am on the community details admin page
    When I remove the slogan
    When I press submit
    And I log out
    Given I am on the homepage
    Then I should not see slogan

  @javascript
  Scenario: Custom community description
    When I am on the homepage
    Then I should see description "This is a place to sell, rent, swap and share goods"

  @javascript
  Scenario: Admin removes the description
    And I am logged in as "kassi_testperson1"
    And I am on the community details admin page
    When I remove the description
    When I press submit
    And I log out
    Given I am on the homepage
    Then I should not see description