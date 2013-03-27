Feature: User joins an organization
  In order to use a community where I can represent an organization
  As a user and a member of an organization
  I want to be able to join and organization when joining the tribe (actually that's even required)
  
  @javascript
  Scenario: user makes new account and joins existing organization
    Given community "test" requires organization membership
    And there is an organization "Corporation Example" 
    # TODO add above    with email requirement "@example.com"
    And I am not logged in
    And I am on the signup page
    When I fill in "person[username]" with random username
    And I fill in "Given name" with "Testmanno"
    And I fill in "Family name" with "Namez"
    And I fill in "person_password1" with "test"
    And I fill in "Confirm password" with "test"
    And I fill in "Email address" with "new.corporate.guy@example.com"
    And I check "person_terms"
    And I press "Create account"
    Then I should see "This community requires every member to represent an organization"
    
    When I select "Corporation Example" from "organization_id" 
    #Then I should see "You need email @example.com"
    #When I fill in "email address" with "richard@example.com"
    And I press "Join community"
    Then I should see "Confirm your email"
    
    When wait for 1 seconds
    Then "new.corporate.guy@example.com" should receive 1 email
    When I open the email
    And I click the first link in the email
    Then I should have 2 emails
    And I should see "Your account was successfully confirmed"
    # Check org membership
  
  @javascript
  Scenario: user logs in and joins an organization that she creates
    Given community "test2" requires organization membership
    #And there is an organization "Coop Example" 
    #with email requirement "@examplecoop.com"
    And I am logged in as "kassi_testperson"
    When I move to community "test2"
    And I am on the home page
    Then I should see "Join community"
    When I check "community_membership_consent"
    And I press "Join community"
    Then I should see "You need to choose an organization."
    
    When I follow "Create new organization"
    Then I should see "Create new organization"
    
    When I fill in "Name" with "My super corporation"
    And I press "Create"
    
    Then I should see "Join community"
    When I select "My super corporation" from "organization_id" 
    When I check "community_membership_consent"
    And I press "Join community"
    
    Then I should see "Post a new listing"
  
  
  
