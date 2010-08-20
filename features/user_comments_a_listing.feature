Feature: User comments a listing
  In order to take part into discussion about a listing
  As a person who is viewing the listing
  I want to be able to comment the listing

  Scenario: Adding a new comment successfully
    And there is favor request with title "Massage" from "kassi_testperson1"
    And I am logged in as "kassi_testperson2"
    When I follow "Massage"
    And I fill in "comment_content" with "Test comment"
    And I press "Send comment"
    Then I should see "Comment created" within "#comment_notice"
    And I should see "Test comment" within "#comments"
  
  
  
  
