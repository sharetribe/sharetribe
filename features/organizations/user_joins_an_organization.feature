Feature: User joins an organization
  In order to use a community where I can represent an organization
  As a user and a member of an organization
  I want to be able to join and organization when joining the tribe (actually that's even required)
  
  
  Scenario: user makes new account and joins existing organization
    Given community "test" requires organization membership
    And I am not logged in
    And I am on the signup page
    When I fill in "person[username]" with random username
    And I fill in "Given name" with "Testmanno"
    And I fill in "Family name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with random email
    And I check "person_terms"
    And I press "Create account"
    Then I should see "In this community you need to be member of an organization"
    
    When I choose "Corporation Example"
    Then I should see "You need email @example.com"
    When I fill in email
    And I press submit
    Then I should see "Confirm your email"
    
    #When wait for 1 seconds
    Then I should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "Your account was successfully confirmed"
    # Check org membership
  
  Scenario: user logs in and joins an organization that she creates
    Given context
    When event
    Then outcome
  
  
  
  
  
