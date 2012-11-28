Feature: User sends feedback to admins
  In order to uggest a new feature, report a bug, or tell my opinion about Kassi
  As a user of Kassi
  I want to be able to give feedback to Kassi administrators
  
  @javascript
  Scenario: Giving feedback successfully when not logged in
    Given I am on the home page
    When I follow "Feedback"
    And I fill in "Your email address" with "test@example.com"
    And I fill in "Feedback to Sharetribe staff" with "Feedback"
    And I press "Send feedback"
    Then I should see "Thanks for your feedback!" within "#notifications"
  
  @javascript
  Scenario: Giving feedback successfully when logged in
    Given I am logged in
    When I follow "Feedback"
    And I should not see "Your email"
    And I fill in "Feedback to Sharetribe staff" with "Feedback"
    And I press "Send feedback"
    Then I should see "Thanks for your feedback!"
  
  @javascript
  Scenario: Trying to give invalid feedback
    Given I am on the home page
    When I follow "Feedback"
    And I fill in "Your email address" with "test"
    And I press "Send feedback"
    Then I should see "This field is required"
    And I should see "Please enter a valid email address"
    
  @javascript
  Scenario: Trying to send a spam link
    Given I am logged in
    When I follow "Feedback"
    And I fill in "Feedback to Sharetribe staff" with "[url=testi"
    And I press "Send feedback"
    Then I should see "Feedback not saved, due to its formatting. Try again or use the feedback forum." within ".error"
    When I follow "Feedback"
    And I fill in "Feedback to Sharetribe staff" with "<a href="
    And I press "Send feedback"
    Then I should see "Feedback not saved, due to its formatting. Try again or use the feedback forum."
  

  
