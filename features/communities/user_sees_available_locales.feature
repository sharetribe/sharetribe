Feature: User sees available locales
  In order to have relevant languages available in own community
  As a user
  I want to see only the relevant languages in the languages list
  
  @javascript
  Scenario: User comes to multiple locale community
    Given the test community has following available locales:
      | locale |
      | fi |
      | en |
    When I am on the home page
    And I click ".select-language"
    Then I should see "English" within ".language-menu"
    Then I should see "Suomi" within ".language-menu"
    Then I follow "English" within ".language-menu"
    And I should see "Post a new listing" within "#post_new_listing"
    And I click ".select-language"
    And I follow "Suomi" within ".language-menu"
    Then I should see "Lisää uusi ilmoitus!" within "#post_new_listing"
    
  Scenario: User comes to single locale community
    Given the test community has following available locales:
      | locale |
      | en |
    When I am on the home page
    Then I should not see selector "#locale_select_padding"
    And I should see "Post a new listing" within "#post_new_listing"
  
  @javascript
  Scenario: There are no locales in community settings
    Given the test community has following available locales:
      | locale |
    When I am on the home page
    And I click ".select-language"
    Then I should see "Pусский" within ".language-menu"
    Then I should see "Suomi" within ".language-menu"
    Then I follow "Pусский" within ".language-menu"
    And I should see "Разместить новый листинг!" within "#post_new_listing"
    And I click ".select-language"
    And I follow "Suomi" within ".language-menu"
    Then I should see "Lisää uusi ilmoitus!" within "#post_new_listing"
  
  
  
