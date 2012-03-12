Feature: User views private community
  In order to keep private communities content private
  As a private community admin
  I want that unlogged users see only the login page when a browsing private communitiy
  
  Scenario: User arrives to the root path of a private community
    Given there are following users:
      | person | 
      | kassi_testperson1 |
    And community "test" is private
    And I am not logged in
    When I go to the homepage #assume getting redirected
    Then I should be on the english private community sign in page
    Then I should not see "Requests"
    And I should see "Create a new account"
    When I log in to this private community as "kassi_testperson1"
    Then I should not see "Create a new account"
    And I should see "Requests"
    
  Scenario: User arrives to other paths in the private community
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
  
  
    
  
  
  
  
