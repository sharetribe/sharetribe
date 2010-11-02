Feature: User logging in and out
  In order to log in and out of Kassi
  As a user
  I want to be able to enter username and password and log in to Kassi and also log out
  
  Scenario: logging in successfully
    Given I am not logged in
    When I enter correct credentials
    Then I should be logged in
  
  Scenario: trying to log in with false credentials

    
  Scenario: logging out
  
  
  Scenario: Seeing my name or username on header after login
    Given I am logged in
    And my given name is "John"
    When I am on the home page
    Then I should see "John"
  
  # TODO: THIS SHOULD BE CHANGED, STUBBED OR STH to not hardcode the "ripa" here and not depend on what's in ASI DB
  
  
  
  
  
  
  

  
  
