Feature: User profile data
  In order to see and edit my own profile data and see profiles of others
  As a Kassi user
  I want to be able to modify my profile details and see profile of any user
  
  Scenario: Entering first name and last name and viewing them
    Given a logged in user
    When I set my first name to Will and last name to Johnson
    Then I should see "Will Johnson" on my profile page
  
  
  
  
  
