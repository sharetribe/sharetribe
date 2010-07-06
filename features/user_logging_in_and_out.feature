Feature: User logging in and out
  In order to log in and out of Kassi
  As a user
  I want to be able to enter username and password and log in to Kassi and also log out

  Scenario: logging in succesfully
    Given user who is not logged in
    When user enters correct credentials
    Then user should be logged in
  
  Scenario: trying to log in with false credentials
    Given context
    When event
    Then outcome
    
  Scenario: logging out
    Given context
    When event
    Then outcome
  
  
  
  
  
  

  
  
