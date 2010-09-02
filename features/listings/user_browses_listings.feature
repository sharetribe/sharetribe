Feature: User browses listings
  In order to find out what kind of offers and requests there are available in Kassi
  As a person who needs something or has something
  I want to be able to browse offers and requests

  Scenario: User browses offers page
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I follow "Settings"
    And I fill in "given_name" with "Test"
    And I fill in "family_name" with "Dude"
    And I fill in "street address" with "Test street 666"
    And I fill in "postal code" with "66666"
    And I fill in ""  
    When event
    Then outcome
    
  Scenario: User browses requests page
    Given context
    When event
    Then outcome
  
    
  
  
  
