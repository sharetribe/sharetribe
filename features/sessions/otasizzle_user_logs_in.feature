Feature: Otasizzle user logs in
  In order to start using Kassi
  As a person who has created an OtaSizzle account in another OtaSizzle service but has not logged in to Kassi before
  I want to log in to Kassi for the first time
  
  Scenario: User logs in and accepts the terms
    Given I already have an OtaSizzle account
    And I am on the home page
    When I follow "Log in"
    And I fill in username with my OtaSizzle username
    And I fill in password with my OtaSizzle password
    And I press "Log in"
    Then I should see "Accepting Kassi terms of use"
    And I press "I accept the terms"
    And I should see "Welcome to Kassi" within "#notifications"
    And I should see "Logout"
  
  Scenario: User logs in but does not accept the terms
    Given I already have an OtaSizzle account
    And I am on the home page
    When I follow "Log in"
    And I fill in username with my OtaSizzle username
    And I fill in password with my OtaSizzle password
    And I press "Log in"
    Then I should see "Accepting Kassi terms of use"
    And I follow "Home"
    And I should see "Log in"
    And I should not see "Logout"
  
  
  
  
  
  

  
