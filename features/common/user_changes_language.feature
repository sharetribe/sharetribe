Feature: User changes language
  In order to view the Sharetribe UI in a different language
  As a person who speaks that language
  I want to be able to change language

  @javascript
  Scenario: User changes language without logging in
    Given I am on the home page
    When I follow "new-listing-link"
    And I click the community logo
    And I open language menu
    And I select "Suomi" from the language menu
    Then I should see "Lisää uusi ilmoitus!" within "#new-listing-link"

  @javascript
  Scenario: User changes language when logged in
    Given I am logged in
    And I open language menu
    And I select "Suomi" from the language menu
    Then I should see "Lisää uusi ilmoitus!" within "#new-listing-link"