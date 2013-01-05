Feature: User creates a new account
  In order to log in to Sharetribe
  As a person who does not have an account in Sharetribe
  I want to create a new account in Sharetribe
  
  @javascript  
  Scenario: Creating a new account successfully
    Given I am not logged in
    And I am on the signup page
    Then I should not see "This community is only for"
    When I fill in "Username:" with random username
    And I fill in "Given name:" with "Testmanno"
    And I fill in "Family name:" with "Namez"
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should see "Welcome to Sharetribe, Testmanno!" within ".flash-notifications"
    And I should not see my username
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
    Then I should see "This username is already in use." 
  
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
    Then I should see "Username is invalid." 
  
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
    Then I should see "The email you gave is already in use." 
  
  @javascript
  Scenario: Trying to create an account without given name and last name
    Given I am not logged in
    And I am on the signup page
    When I fill in "Username:" with random username
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
    Then I should see "Welcome to Sharetribe" within ".flash-notifications"
  
  @javascript  
  Scenario: Creating a new account without allowing to show real name
    Given I am not logged in
    And I can choose whether I want to show my username to others in community "test"
    And I am on the signup page
    And I fill in "Username:" with random username
    And I fill in "Given name:" with "Testmanno"
    And I fill in "Family name:" with "Namez"
    And I uncheck "person_show_real_name_to_other_users"
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should see my username
    And I should not see "Testmanno"
    And I should not see "Testmanno!"
    And Most recently created user should be member of "test" community with its latest consent accepted
  
  @javascript  
  Scenario: Creating a new account and allowing to show real name
    Given I am not logged in
    And I can choose whether I want to show my username to others in community "test"
    And I am on the signup page
    And I fill in "Username:" with random username
    And I fill in "Given name:" with "Testmanno"
    And I fill in "Family name:" with "Namez"
    And I fill in "Password:" with "test"
    And I fill in "Confirm password:" with "test"
    And I fill in "Email address:" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should not see my username
    And I should see "Testmanno!"
    And Most recently created user should be member of "test" community with its latest consent accepted
    
  @subdomain2  
  Scenario: Seeing info of community's email restriction
    Given I am not logged in
    When I go to the signup page
    Then I should see "This community is only for Test2. To join you need a '@example.com' email address."
  
  
  
