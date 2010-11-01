Feature: User comments a listing
  In order to take part into discussion about a listing
  As a person who is viewing the listing
  I want to be able to comment the listing

  @javascript
  Scenario: Adding a new comment successfully
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And I am logged in as "kassi_testperson2"
    When I follow "Massage"
    And I fill in "comment_content" with "Test comment"
    And I press "Send comment"
    Then I should see "Comment sent" within "#comment_notice"
    And I should see "Test comment" within "#comments"
  
  @javascript
  Scenario: Trying to add a new comment without content
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And I am logged in as "kassi_testperson2"
    When I follow "Massage"
    And I press "Send comment"
    Then I should see "This field is required." within ".error"
      
  Scenario: Trying to add a comment without logging in
    Given there are following users:
      | person | 
      | kassi_testperson1 |
      | kassi_testperson2 |
    And there is favor request with title "Massage" from "kassi_testperson1"
    And I am not logged in
    And I am on the home page
    When I follow "Massage"
    Then I should see "You must log in to send a new comment."
    And I should not see "Write a new comment:"
  
  
    
  
  
  
  
  
  
