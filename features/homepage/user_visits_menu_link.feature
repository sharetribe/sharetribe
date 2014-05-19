@javascript
Feature: User visits menu link

  Background:
    Given there is a menu link "Blog" to "http://blog.sharetribe.com/"
    And I am on the homepage

  Scenario:
    When I open the menu
    Then I should see "Blog" on the menu
    When I follow "Blog"
    Then I should be on URL http://blog.sharetribe.com/