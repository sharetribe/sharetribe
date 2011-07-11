Feature: User views dashboard
  In order to read stuff about Kassi
  As a user
  I want to be able to view the dashboard
  
  @no_subdomain
  @javascript
  Scenario: User views dashboard
    Given I am on the home page
    Then I should see "Kassi - share goods, favors and rides in your local community!"
  
  @no_subdomain
  @javascript
  Scenario: User changes dashboard language
    Given I am on the home page
    When I select "Finnish" from "locale"
    Then I should see "Kassi - jaa tavaroita, palveluksia ja kyytejä paikallisyhteisössäsi!"

  
