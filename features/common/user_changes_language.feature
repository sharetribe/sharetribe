Feature: User changes language
  In order to view the Sharetribe UI in a different language
  As a person who speaks that language
  I want to be able to change language

  @javascript
  Scenario: User changes language without logging in
    Given I am on the home page
    When I follow "Post a new listing"
    And I follow "Home" 
    And I click ".select-language"
    Then I follow "Suomi" within ".language-menu"
    Then I should see "Lisää uusi ilmoitus!" within "#post_new_listing"
  
  @javascript
  Scenario: User changes language when logged in
    Given I am logged in
    When I click ".select-language"
    And I follow "Suomi" within ".language-menu"
    Then I should see "Lisää uusi ilmoitus!" within "#post_new_listing"
  
  
  
  
  
  

    
  
