Feature: User views info about kassi
  In order to find information about the service
  As a new user
  I want to be able to read about Kassi

  Scenario: User views about page
    Given I am on the home page
    When I follow "About Kassi"
    Then I should see "Information about Kassi" within "h1"
    And I should see "What is Kassi?" within ".inbox_tab_selected"
    And I should see "How to use Kassi" within ".inbox_tab_unselected"
    And I should see "Terms of use" within ".inbox_tab_unselected"
    And I should see "Register details" within ".inbox_tab_unselected"
    And I should see "Who is Kassi for?" within "h3"
  
  Scenario: User views terms page
    Given I am on the home page
    When I follow "About Kassi"
    And I follow "Terms"
    And I should see "What is Kassi?" within ".inbox_tab_unselected"
    And I should see "How to use Kassi" within ".inbox_tab_unselected"
    And I should see "Terms of use" within ".inbox_tab_selected"
    And I should see "Register details" within ".inbox_tab_unselected"
    And I should see "Rights of content" within "h3"
  
  Scenario: User views how to use page without logging in
    Given I am on the home page
    When I follow "About Kassi"
    And I follow "How to use Kassi"
    And I should see "What is Kassi?" within ".inbox_tab_unselected"
    And I should see "How to use Kassi" within ".inbox_tab_selected"
    And I should see "Terms of use" within ".inbox_tab_unselected"
    And I should see "Register details" within ".inbox_tab_unselected"
    And I should see "Offer items and favors to others" within "h3"
    And I should not see "messages view" within "a"
  
  Scenario: User views how to use page when logged in
    Given I am logged in
    When I follow "About Kassi"
    And I follow "How to use Kassi"
    And I should see "What is Kassi?" within ".inbox_tab_unselected"
    And I should see "How to use Kassi" within ".inbox_tab_selected"
    And I should see "Terms of use" within ".inbox_tab_unselected"
    And I should see "Register details" within ".inbox_tab_unselected"
    And I should see "Offer items and favors to others" within "h3"
    And I should see "messages view" within "a"
    
  Scenario: User views register details page
    Given I am on the home page
    When I follow "About Kassi"
    And I follow "Register details"
    And I should see "What is Kassi?" within ".inbox_tab_unselected"
    And I should see "How to use Kassi" within ".inbox_tab_unselected"
    And I should see "Terms of use" within ".inbox_tab_unselected"
    And I should see "Register details" within ".inbox_tab_selected"
    And I should see "Name of the register" within "h3"
  
  
  
  
  
  
  
