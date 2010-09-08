Feature: User changes language
  In order to view the Kassi UI in a different language
  As a person who speaks that language
  I want to be able to change language

  @pending
  @javascript
  Scenario: User changes language without logging in
    Given I am on the home page
    When I select "Finnish" from "locale"
    Then I should see "Tarjoa jotakin" within "offer_something_button"
  
  @pending
  @javascript
  Scenario: User changes language when logged in
    Given I am logged in
    When I select "Finnish" from "locale"
    Then I should see "Tarjoa jotakin" within "offer_something_button"
  
  
  
  
  
  

    
  
