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
    And I should see "Follow this listing"
    And I should not see "Stop following this listing"
    And I fill in "comment_content" with "Test comment"
    And I press "Send comment"
    Then I should see "Comment sent" within "#comment_notice"
    And I should see "Test comment" within "#comments"
    And the system processes jobs
    And I should not see "Follow this listing"
    And I should see "Stop following this listing"
    When I follow "Logout"
    And I log in as "kassi_testperson1"
    Then I should see "1" within "#logged_in_notifications_icon"
    When I follow "notifications_link"
    Then I should see "has commented on your request"
    When I follow "your request"
    And I fill in "comment_content" with "Test answer"
    And I press "Send comment"
    And the system processes jobs
    And I follow "Logout"
    And I log in as "kassi_testperson2"
    And the system processes jobs
    And I go to the home page
    Then I should see "1" within "#logged_in_notifications_icon"
    When I follow "notifications_link"
    Then I should see "has commented on a request you follow"
    When I follow "a request you follow"
    And I fill in "comment_content" with "Test comment 2"
    And I uncheck "comment_author_follow_status"
    And I press "Send comment"
    Then I should see "Follow this listing"
    And I should not see "Stop following this listing"
    When I follow "Follow this listing"
    Then I should see "You are now following this listing" within "#notifications"
    When I follow "Logout"
    And I log in as "kassi_testperson1"
    And I follow "Massage"
    And I fill in "comment_content" with "Test answer 2"
    And I press "Send comment"
    And I follow "Logout"
    And I log in as "kassi_testperson2"
    And the system processes jobs
    Then I should not see "1" within "#logged_in_notifications_icon"
  
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
    Then I should see "This field is required."
      
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