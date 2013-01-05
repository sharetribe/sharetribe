Feature: User views terms
  In order to check what terms I am accepting when I register to Sharetribe
  As a user
  I want to be able to 

  @javascript
  @fix_for_new_design
  Scenario: User views terms in community Test
    Given I am not logged in
    And I am on the signup page
    When I follow "terms"
    Then I should see "Rights of Content"
  
  @javascript
  @subdomain2
  @fix_for_new_design
  Scenario: User views terms in community Test2
    Given I am not logged in
    And I am on the signup page
    When I follow "terms"
    Then I should see "This is another community"
  
  
  
  
  
