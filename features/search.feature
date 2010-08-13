Feature: Search
  In order to find needed contents
  As a user
  I want to search listings by typing a keyword to search box and hitting enter
  
  # The reason may be that the delta indexing is not working in test env?
  @wip 
  @pending
  Scenario: basic search
    Given there is item offer with title "old sofa for sale"
    And I am on the home page
    When I fill in "q" with "sofa"
    And I press "search"
    Then I should see "results"
    And show me the page
    And I should see "old sofa for sale"
    
  
  
  

  
