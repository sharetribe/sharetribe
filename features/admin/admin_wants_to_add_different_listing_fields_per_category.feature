Feature: Admin wants to add different listing fields per category

  Background:
    Given "kassi_testperson" has admin rights for community "test"
    And I am logged in as "kassi_testperson"

  Scenario: Admin can browse to category fields page from homepage
    Given I am on the homepage
    When I browse to the category fields admin page
    Then I should be in the category fields admin page

  Scenario: Admin adds listing field to item category
    Given I am on the category fields admin page
    And I add a new dropdown field with options:
      | options |
      | sport car |
      | family car |
    And I save the changes
    When I go to new listing page
    And I add a new listing with category "item"
    Then I should see dropdown field with options:
      | options |
      | sport car |
      | family car |