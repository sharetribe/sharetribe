Feature: User sees available locales
  In order to have relevant languages available in own community
  As a user
  I want to see only the relevant languages in the languages list

  @javascript
  Scenario: User comes to multiple locale community
    Given the test community has following available locales:
      | locale |
      | en |
      | fi |
    When I am on the home page
    And I open language menu
    Then I should see "English" on the language menu
    Then I should see "Suomi" on the language menu
    Then I select "English" from the language menu
    And I should see "Post a new listing" within "#new-listing-link"
    And I open language menu
    And I select "Suomi" from the language menu
    Then I should see "Lisää uusi ilmoitus!" within "#new-listing-link"

  Scenario: User comes to single locale community
    Given the test community has following available locales:
      | locale |
      | en |
    When I am on the home page
    Then I should not see selector "#locale_select_padding"
    And I should see "Post a new listing" within "#new-listing-link"

  @javascript
  Scenario: There are no locales in community settings
    Given the test community has following available locales:
      | locale |
    When I am on the home page
    And I open language menu
    And I select "Suomi" from the language menu
    Then I should see "Lisää uusi ilmoitus!" within "#new-listing-link"



