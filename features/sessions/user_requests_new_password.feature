Feature: User requests new password
  In order to retrieve a new password
  As a user who has forgotten his password
  I want to request a new password
  
  @javascript
  Scenario: User requests new password successfully
    Given I am on the home page
    When I click ".login-menu-toggle"
    And I follow "Username or password forgotten"
    And I fill in "Email" with "kassi_testperson2@example.com"
    And I press "Request new password"
    Then I should see "Instructions to change your password were sent to your email." within ".flash-notifications"
   
  @javascript 
  Scenario: title
    Given I am on the home page
    When I click ".login-menu-toggle"
    And I follow "Username or password forgotten"
    And I fill in "Email" with "some random string"
    And I press "Request new password"
    Then I should see "The email you gave was not found from Sharetribe database." within ".flash-notifications"
  
  
  
  
  
  

  
