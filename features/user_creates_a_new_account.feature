Feature: User creates a new account
  In order to log in to Kassi
  As a person who does not have an account in Kassi
  I want to create a new account in Kassi
  
  @pending
  Scenario: Creating a new account successfully
    Given I am not logged in
    And I am on the home page
    When I follow "Sign up"
    And I fill in "Username:" with "test"
    And I fill in "Given name:" with "Test"
    And I fill in "Family name:" with "Name"
    And I fill in "Password:" with "test"
    And I fill in "Password again:" with "test"
    And I fill in "Email:" with "test@test.com"
    Then I should see "Welcome to Kassi, Test Name!" within "#notifications"
  
  @pending
  Scenario: Trying to create a new listing and registering when prompted
    Given context
    When event
    Then outcome
  
  
  
  
  
  

  
