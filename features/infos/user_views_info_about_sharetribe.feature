Feature: User views info about sharetribe
  In order to find information about the service
  As a new user
  I want to be able to read about Kassi

  @javascript
  Scenario: User views about page
    Given I am on the home page
    When I follow "About"
    Then I should see "Information about Sharetribe" within "h1"
    And I should see "What is it" within ".inbox_tab_selected"
    And I should see "How to use" within ".inbox_tab_unselected"
    And I should see "Terms of use" within ".inbox_tab_unselected"
    And I should see "Register details" within ".inbox_tab_unselected"
    And I should see "Who's behind Sharetribe?" within "h3"
  
  @javascript
  Scenario: User views terms page
    Given I am on the home page
    When I follow "About"
    And I follow "Terms"
    And I should see "What is it" within ".inbox_tab_unselected"
    And I should see "How to use" within ".inbox_tab_unselected"
    And I should see "Terms of use" within ".inbox_tab_selected"
    And I should see "Register details" within ".inbox_tab_unselected"
    And I should see "Rights of Content" within "h3"
  
  @javascript
  Scenario: User views how to use page without logging in
    Given I am on the home page
    When I follow "About"
    And I follow "How to use"
    And I should see "What is it" within ".inbox_tab_unselected"
    And I should see "How to use" within ".inbox_tab_selected"
    And I should see "Terms of use" within ".inbox_tab_unselected"
    And I should see "Register details" within ".inbox_tab_unselected"
    And I should see "Offer items and favors to others" within "h3"
    And I should not see "messages view" within "a"
  
  @javascript
  Scenario: User views how to use page when logged in
    Given I am logged in
    When I follow "About"
    And I follow "How to use"
    And I should see "What is it" within ".inbox_tab_unselected"
    And I should see "How to use" within ".inbox_tab_selected"
    And I should see "Terms of use" within ".inbox_tab_unselected"
    And I should see "Register details" within ".inbox_tab_unselected"
    And I should see "Offer items and favors to others" within "h3"
    And I should see "messages view" within "a"
  
  @javascript
  Scenario: User views register details page
    Given I am on the home page
    When I follow "About"
    And I follow "Register details"
    And I should see "What is it" within ".inbox_tab_unselected"
    And I should see "How to use" within ".inbox_tab_unselected"
    And I should see "Terms of use" within ".inbox_tab_unselected"
    And I should see "Register details" within ".inbox_tab_selected"
    And I should see "Name of the register" within "h3"