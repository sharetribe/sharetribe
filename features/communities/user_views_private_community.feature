Feature: User views private community
  In order to keep private communities content private
  As a private community admin
  I want that unlogged users see only the login page when a browsing private communitiy
  
  Scenario: user arrives to the root path of a private community
    Given community "test" is private
    And I am not logged in
    And the test community has following available locales:
      | locale |
      | fi |
    When I go to the homepage #assume getting redirected
    Then I should be on the finnish private community sign in page
    And I should see "Voisitko lainata muille tavaroita"
    
  
  Scenario: user arrives to other paths in the private community
    Given community "test" is private
    And I am not logged in
    When I go to the offers page
    Then I should be on the private community sign in page
    When I go to the requests page
    Then I should be on the private community sign in page
    When I go to the infos page
    Then I should be on the private community sign in page
    When I go to the news page
    Then I should be on the private community sign in page
    
    
  
  
  
  
