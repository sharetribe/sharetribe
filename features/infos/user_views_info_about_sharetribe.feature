Feature: User views info about sharetribe
  In order to find information about the service
  As a new user
  I want to be able to read about Kassi

  @javascript
  Scenario: User views about page
    Given I am on the home page
    When I follow "About"
    Then I should see "Sharetribe is a marketplace that makes it easy" within ".about-section"
    And I should see "What is it" within ".left-navi"
    And I should see "What is it" within ".selected.left-navi-link"
    And I should see "How to use" within ".left-navi"
    And I should not see "How to use" within ".selected.left-navi-link"
    And I should see "Terms of use"
    And I should see "Privacy"
    And I should see "Who's behind Sharetribe?"
  
  @javascript
  Scenario: User views terms page
    Given I am on the home page
    When I follow "About"
    And I follow "Terms of use" within ".left-navi"
    And I should see "What is it" within ".left-navi"
    And I should not see "What is it" within ".selected.left-navi-link"
    And I should see "How to use" within ".left-navi"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".left-navi"
    And I should see "Rights of Content"
  
  @javascript
  Scenario: User views how to use page without logging in
    Given I am on the home page
    When I follow "About"
    And I follow "How to use" within ".left-navi"
    And I should see "What is it" within ".left-navi"
    And I should not see "What is it" within ".selected.left-navi-link"
    And I should see "How to use" within ".left-navi"
    And I should see "How to use" within ".selected.left-navi-link"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".left-navi"
    And I should see "Offer items and favors to others"
    And I should not see "your messages view" within ".about-section"
  
  @javascript
  Scenario: User views how to use page when logged in
    Given I am logged in
    When I follow "About"
    And I follow "How to use" within ".left-navi"
    And I should see "What is it" within ".left-navi"
    And I should not see "What is it" within ".selected.left-navi-link"
    And I should see "How to use" within ".selected.left-navi-link"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".left-navi"
    And I should see "Offer items and favors to others" 
    And I should see "your messages view" within ".about-section"
  
  @javascript
  Scenario: User views register details page
    Given I am on the home page
    When I follow "About"
    And I follow "Privacy" within ".left-navi"
    And I should see "What is it" within ".left-navi"
    And I should see "How to use" within ".left-navi"
    And I should see "Terms of use" within ".left-navi"
    And I should see "Privacy" within ".selected.left-navi-link"
    And I should see "Name of the register"
