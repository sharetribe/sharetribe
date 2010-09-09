Feature: User creates a new account
  In order to log in to Kassi
  As a person who does not have an account in Kassi
  I want to create a new account in Kassi
  
  @pending
  @wip
  Scenario: Creating a new account successfully
    Given I am not logged in
    And I am on the home page
    When I follow "Sign up"
    And I fill in "Username:" with random username
    And I fill in "Given name:" with "Testmanno"
    And I fill in "Family name:" with "Namez"
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I press "Create account"
    Then I should see "Welcome to Kassi, Testmanno!" within "#notifications"
    
  @pending  
  Scenario: Trying to create account with unavailable username 
    Given I am not logged in
    And I am on the signup page
    When I fill in "Username" with "kassi_testperson1"
    Then I should see "Username is already taken"
  
  @pending  
  Scenario: Trying to create account with unavailable email
    Given I am not logged in
    And I am on the signup page
    When I fill in "Email address" with "kassi_testperson1@example.com"
    Then I should see "Email is already taken"
  
  
  @pending
  Scenario: Trying to create a new listing and registering when prompted
    Given context
    When event
    Then outcome
  
  
  
  
  
  

  
