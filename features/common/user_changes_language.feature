Feature: User changes language
  In order to view the Sharetribe UI in a different language
  As a person who speaks that language
  I want to be able to change language

  @javascript
  Scenario: User changes language without logging in
    Given I am on the home page
    When I follow "Share with others!"
    And I follow "Home" 
    And I select "Suomi" from "locale"
    Then I should see "Listaa taitosi ja tavarasi!" within "#offer_something_button"
  
  @javascript
  Scenario: User changes language when logged in
    Given I am logged in
    When I select "Suomi" from "locale"
    Then I should see "Listaa taitosi ja tavarasi!" within "#offer_something_button"
  
  
  
  
  
  

    
  
