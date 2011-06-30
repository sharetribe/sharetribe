Feature: User creates a new account
  In order to log in to Kassi
  As a person who does not have an account in Kassi
  I want to create a new account in Kassi
  
  @javascript  
  Scenario: Creating a new account successfully
    Given I am not logged in
    And I am on the signup page
    And I fill in "Username:" with random username
    And I fill in "Given name:" with "Testmanno"
    And I fill in "Family name:" with "Namez"
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should see "Welcome to Kassi, Testmanno!" within "#notifications"
    And Most recently created user should be member of "test" community with its latest consent accepted
  

  @javascript  
  Scenario: Trying to create account with unavailable username 
    Given I am not logged in
    And I am on the signup page
    When I fill in "Username" with "kassi_testperson2"
    And I fill in "Given name:" with "Testmanno"
    And I fill in "Family name:" with "Namez"
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I press "Create account"
    Then I should see "The username you gave is already in use." within ".error"
  
  
  @javascript  
  Scenario: Trying to create account with invalid username 
    Given I am not logged in
    And I am on the signup page
    When I fill in "Username" with "sirkka-liisa"
    And I fill in "Given name:" with "Testmanno"
    And I fill in "Family name:" with "Namez"
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I press "Create account"
    Then I should see "Username is invalid." within ".error"
  
  @javascript
  Scenario: Trying to create account with unavailable email
    Given I am not logged in
    And I am on the signup page
    When I fill in "Username:" with random username
    And I fill in "Given name:" with "Testmanno"
    And I fill in "Family name:" with "Namez"
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address" with "kassi_testperson2@example.com"
    And I press "Create account"
    Then I should see "The email you gave is already in use." within ".error"
  
  @javascript
  Scenario: Trying to create an account without given name and last name
    Given I am not logged in
    And I am on the signup page
    When I fill in "Username:" with random username
    And I fill in "Username:" with random username
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should see "This field is required."
    When given name and last name are not required in community "test"
    And I am on the signup page
    When I fill in "Username:" with random username
    And I fill in "Username:" with random username
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should see "Welcome to Kassi" within "#notifications"
  
  
  
  
  
  

  
