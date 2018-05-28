Feature: User views terms
  In order to check what terms I am accepting when I register to Sharetribe
  As a user
  I want to be able to 

  @javascript
  Scenario: User views terms in community Test
    Given I am not logged in
    And I am on the signup page
    When I follow "Terms of Use"
    Then I should see "Rights of Content"
  
  
  
  
  
