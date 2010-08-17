@no-txn
Feature: Search
  In order to find needed contents
  As a user
  I want to search listings by typing a keyword to search box and hitting enter
  
  # This fails at the moment, probably because indexing or rails3&ts2&cucumber incompatibilities
  @failing
  @wip 
  @pending
  @no-txn
  Scenario: basic search
    Given there is item offer with title "old sofa for sale" and with share type "sell"
    And I am on the home page
    And the Listing indexes are processed
    When I fill in "q" with "sofa"
    And I press "search"
    Then I should see "results"
    And show me the page
    And I should see "old sofa for sale"
    
  
  
  

  
